require "php_serialize"
require "net/http"
require "uri"

class ActiveSape

  def initialize(options = {})
    @@options = options
    @@links_hash = {}
    @@cache_lifetime = options[:cache_lifetime] || 3600
    @@read_timeout_sec = 6
    @@last_update = Time.now - @@cache_lifetime
    @@force_show_code = options['force_show_code'] || false
    @@advert_host = options['advert_host']
    @@user = options['user'] || "97ab6f9a4c02f65e84e3255d304b51b6"
    @@sape_dom = options['sape_dom'] || "dispenser-01.sape.ru"
    @@charset = options['charset'] || "UTF-8"

  end

  def show_links(request, limit)
    get_links_db
    #get offset from current request environment
		offset = request.env["SAPE_OFFSET"].to_i
		#increment offset for current request
    request.env["SAPE_OFFSET"] = request.env["SAPE_OFFSET"].to_i + limit
    request_uri = request.env["REQUEST_URI"]

    is_sape_robot = false
    ["REMOTE_ADDR", "HTTP_X_REAL_IP", "HTTP_X_FORWARDED_FOR"].each do |key|
      ip = request.params[key]
      is_sape_robot = true if ip && @@links_hash["__sape_ips__"].include?(ip)
    end

    if @@force_show_code || is_sape_robot
      resp = @@force_show_code ? ' <!--check code--> ' : ''
#      Rails.logger.info("Sape Boot:  #{@@links_hash["__sape_new_url__"]}")
      "#{resp} #{@@links_hash["__sape_new_url__"]}".strip
    else
      delim = @@links_hash["__sape_delimiter__"]
      if @@links_hash.key?(request_uri)
        links_str = ""
        links = @@links_hash[request_uri][offset.to_i, limit]
        unless links.nil? || links.blank?
#                logger.debug("LINKS: |"+links.inspect+'|')
          links.each{|link| links_str << "#{link} #{delim}"}
        end
        links_str
      end
    end
  end

  def get_links_db(server  = @@sape_dom, port = 80)
    return {} unless @@options['get_links']
    return @@links_hash  if (Time.now < @@last_update + @@cache_lifetime) && !@@links_hash.empty?
#    Rails.logger.info( "NOW: "+Time.now.to_s + " last update #{@@last_update}")
    @@last_update = Time.now

    path = "/code.php?user=#{@@user}&host=#{@@advert_host}&charset=#{@@charset}"

#		Rails.logger.info "path = " + path
    begin
      Net::HTTP.new(server, port).start do |http|
#        Rails.logger.info('UPDATE DB LINKS FOR SAPE')
        http.read_timeout=(@@read_timeout_sec)
        http.request_get(path) { |res|
          @@links_hash ||= {}
#          Rails.logger.info "BODY = " + res.body.inspect
          @@links_hash = PHP.unserialize(res.body) unless res.nil?
        }
        @@links_hash
      end
#	  Rails.logger.info(@@links_hash.inspect)
    rescue Exception => err
#      Rails.logger.error err
    end
  end
end

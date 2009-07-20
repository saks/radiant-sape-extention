require 'active_sape'
module SapeHelper

  @@sape_options = YAML.load_file("#{RAILS_ROOT}/config/sape.yml") rescue {}
  SAPE = ActiveSape.new(@@sape_options)

  def show_sape_links(count)
    '<div>' + SAPE.show_links(request, count) + '</div>'
  end
end

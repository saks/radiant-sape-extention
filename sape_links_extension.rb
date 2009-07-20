# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class SapeLinksExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/sape_links"

  def activate
  	Page.send :include, SapeLinks
  end

  def deactivate
  end

end

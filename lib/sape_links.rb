require 'sape_helper'

module SapeLinks
  include Radiant::Taggable
  include SapeHelper

  desc "Creates an HTML box with a sape links"
  tag "sape_links" do |tag|
    show_sape_links tag.attr['count'] ? tag.attr['count'].to_i : 100
  end
end

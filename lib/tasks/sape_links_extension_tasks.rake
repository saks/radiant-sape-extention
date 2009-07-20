require "fileutils"

namespace :radiant do
  namespace :extensions do
    namespace :sape_links do

      desc "Runs the migration of the Sape Links extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        	plugin_root = File.join(RAILS_ROOT, "vendor", "extensions", "active_sape")
        	FileUtils.cp(File.join(plugin_root, "sape.yml"), File.join(RAILS_ROOT, "config"))
        end
      end

      desc "Copies public assets of the Sape Links to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from SapeLinksExtension"
        Dir[SapeLinksExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(SapeLinksExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end
    end
  end
end

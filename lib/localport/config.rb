##
# Cofigure localport
# 
require 'rubygems'
require 'highline'

module LocalPort
  HOME = ENV['HOME']
  LocalPort::CONF_DIR = "#{HOME}/.localport"
  LocalPort::CONF_FILE = LocalPort::CONF_DIR + "/config"
  

  class Config
    
    attr_reader :installed, :activated

    def self.instance
      @config ||= new
    end

    def initialize
      @installed = {}
      @activated = {}
    end

    def setup
      ui = HighLine.new
      apps_dir = ui.ask("Where is your applications directory: ")
      link_dir = ui.ask("Where is your link directory: ")
      config = template(apps_dir, link_dir) 
      Dir.mkdir(LocalPort::CONF_DIR) unless File.exist? LocalPort::CONF_DIR
      File.open(LocalPort::CONF_FILE, 'w') {|io|
        io << config
      }
    end

    def template(apps_dir, link_dir)
"LocalPort::APPS_DIR = '%s'
LocalPort::LINK_DIR = '%s'" % [apps_dir, link_dir]
    end

    def installed_app
      dir = LocalPort::LINK_DIR
      symlinks = Dir["#{dir}/*"]
      symlinks.each do |symlink|
        next unless File.symlink? symlink
        
        src = File.readlink symlink
        same_dir_p = same_dir?(src, symlink)
        if same_dir_p
          symlink = src
          src = File.readlink(src)
        end
        # APPS_DIRから各appの階層を計算する
        # NOTE: APPS_DIRの直下がappであることを前提にしている
        # e.g. /Users/user/apps/app1
        #                      /app2
        # => 4
        level = LocalPort::APPS_DIR.split('/').size
        app = src.split('/')[level]

        # e.g. ruby-1.8.7-p160 => 1.8.7-p160
        symlink_base = File.basename symlink
        src_base = File.basename src
        version = symlink_base.gsub(/#{src_base}-?/, '')

        # srcがカレントにあるリンクを指しているのなら
        # それがそのアプリのカレントファイルになる．
        # @appsには追加しなくてよい
        if same_dir_p
          add_activated(app, version)
          next
        end
        
        @installed[app] ||= {}
        app_versions = @installed[app]
        app_versions[version] ||= []
        app_version = app_versions[version]
        app_version << symlink unless app_version.include? symlink
      end
    end

    def same_dir?(src, symlink)
      File.dirname(src) == File.dirname(symlink)
    end

    def add_activated(app, version)
      @activated[app] = version unless @activated[app] 
    end
  end
end

def config
  LocalPort::Config.instance
end

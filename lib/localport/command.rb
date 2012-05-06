# -*- coding: utf-8 -*-
#
# Definition localport commands
#
require 'localport/config'

module LocalPort
  class CommandError < ::StandardError; end
  class Command
    attr_reader :commands

    def self.instance
      @command ||= new
    end

    def initialize
      @commands = {}
      register_command(
        :name => "install",
        :args => true,
        :exec => lambda {|args|
          if args.empty?
            raise LocalPort::CommandError, "must specify to installed application path."
          end
          install args
        }
      )

      register_command(
        :name => "update",
        :args => true,
        :exec => lambda {|args|
          update args
        }
      )

      register_command(
        :name => "uninstall",
        :args => true,
        :exec => lambda {|args|
          uninstall args
        }
      )

      register_command(
        :name => "installed",
        :args => false,
        :exec => lambda {|args|
          if args.size > 0
            args.each do |app|
              puts "#{app}:"
              config.installed[app].keys.each {|ver|
                puts_version(app, ver)
              }
            end
          else
            config.installed.each do |app, versions|
              puts "#{app}:"
              versions.keys.each {|ver|
                puts_version(app, ver)
              }
            end
          end
        }
      )

      register_command(
        :name => "activate",
        :args => true,
        :exec => lambda {|args|
          if args.empty?
            raise LocalPort::CommandError, "must specify verbose application name. {app}-{version}"
          end
          args.each {|app| activate app }
        }
      )

      register_command(
        :name => "deactivate",
        :args => true,
        :exec => lambda {|args|
          if args.empty?
            raise LocalPort::CommandError, "must specify verbose application name. {app}-{version}"
          end
          args.each {|app| deactivate app }
        }
      )
    end

    def puts_version(app, ver)
      status = config.activated[app] == ver ? '*' : ' '
      puts " %s #{ver}" % status
    end

    def list
      @commands.keys
    end

    def install(paths=[])
      paths.each do |path|
        bins = Dir[sanitize(path) + "/bin/*", sanitize(path) + "/sbin/*"]
        symlinks(bins).each {|bin, link|
          File.symlink(bin, link) unless File.exist? link
        }
      end
    end

    def update(args)
      targets = update_apps(args)
      targets.each {|target|
        install([installed_dir(target)])
        config.installed_app() # TODO: もっとエレガントに初期化する方法を考える
        activate(target)
      }
    end

    def uninstall(args)
      # 指定されたアプリケーションがactivatedされていなければ，
      # そのリンクを削除する
      args.each do |arg|
        app, ver = split_appver_to_app_ver arg
        unless activated? app, ver
          symlinks = config.installed[app][ver]
          if symlinks
            symlinks.each do |symlink|
              File.unlink(symlink) if File.exist? symlink
            end
          else
            puts "#{app}-#{ver} is not installed."
          end
        else
          puts "#{app}-#{ver} is activated. Please deactivate this app before uninstalling"
        end
      end
    end

    def activate(appver)
      # 指定されたアプリがactivateされていたら，エラーを吐いて終了
      # NOTE: activatedされていたversionと指定したversionが同じであればactivateを実行する
      #       localportの問題点として，新にbin/以下に実行ファイルが追加される．
      #       その場合，install -> activateという流れを踏まなければならず，
      #       activateされているにもかかわらず同じバージョンの場合はactivate
      #       を実行しなければならない
      #       違うバージョンのときのみにエラーを吐く
      app, ver = split_appver_to_app_ver(appver)
      if activated_ver = config.activated[app]
        if activated_ver != ver
          raise ArgumentError, "already activated *#{app}-#{activated_ver}*\nplease deactivate first"
        end
      end
      create_symlink(app, ver)
    end

    def activated?(app, ver)
      config.activated[app] == ver
    end

    def deactivate(name)
      # 指定されたnameに対応するリンクを削除する
      app, ver = split_appver_to_app_ver(name)

      if config.activated[app] == ver
        delete_symlink(app, ver)
      end
    end

    def split_appver_to_app_ver(appver)
      app = config.installed.keys.select {|k|
        /^#{k}/ =~ appver
      }.reject {|x| x.nil? || x.empty? }.first
      ver = appver.gsub(/#{app}-?/, '')

      [app, ver]
    end

    def register_command(arg)
      @commands[arg[:name]] = arg
    end

    def find(name)
      raise LocalPort::CommandError, "'#{name}' is not a localport command." unless @commands.key? name
      @commands[name]
    end

    def create_symlink(app, ver)
      srcs = config.installed[app][ver]
      srcs.each do |src|
        new = src.gsub(/-?#{ver}/, '')
        File.symlink(src, new) unless File.exist? new
      end
    end

    def delete_symlink(app, ver)
      srcs = config.installed[app][ver]
      srcs.map {|src|
        src.gsub(/-?#{ver}$/, '')
      }.each {|src|
        File.unlink src if File.exist? src
      }
    end

    def sanitize(path)
    # pathの最後から'/'を取り除く
      raise ArgumentError, "#{path} does not exist." unless File.exist? path
      if path[-1].chr == '/'
        path = path.chop
      end
      path
    end

    def symlinks(bins)
      bins.inject({}) {|ret, bin|
        bin_app = bin.split('/')[-4] # => vim
        bin_version = bin.split('/')[-3] # => 7.2
        bin_name = File.basename bin # => vim
        bin_ext = File.extname bin
        link = File.join(LocalPort::LINK_DIR,
                         (bin_name.gsub(bin_ext, '') + "-"+ bin_version + bin_ext))
        ret[bin] = link
        ret
      }
    end

    # Private: [指定した]アプリケーションのバージョンをつけた文字列配列を生成する
    #
    # args - [String], アプリケーションの配列
    #
    # Examples:
    #
    #   update_apps ["ruby"]
    #   #=> ["ruby-1.9.2-p130"]
    #
    # Returns アプリケーションのバージョンがついた文字列配列
    def update_apps(args)
      if args.empty?
        config.installed.inject([]) {|ret, (app, versions)|
          ret += versions.keys.map {|version| "#{app}-#{version}"}
          ret
        }
      else
        args.inject([]) {|ret, arg|
          versions = config.installed[arg]
          if versions
            ret += versions.keys.map {|version| "#{arg}-#{version}"}
          end
          ret
        }
      end
    end

    # Private: 指定したアプリケーションがインストールされているディレクトリ名を生成する
    #
    # app - String, バージョン付きアプリケーション名
    #
    # Examples:
    #
    #   installed_dir "ruby-1.9.3-p130"
    #   #=> /Users/user/local/ruby/1.9.3-p130
    #
    # Returns アプリケーションがインストールされているディレクトリ名
    def installed_dir(appver)
      app, ver = split_appver_to_app_ver(appver)
      File.join(LocalPort::APPS_DIR, app, ver)
    end
  end

  def self.command
    LocalPort::Command.instance
  end
end


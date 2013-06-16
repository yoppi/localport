# -*- coding: utf-8 -*-
#
# Add the directory containing this file to the start of the load path
# if it doesn't include alreadry.
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include? libdir

require 'localport/config'
require 'localport/command'

##
# Local Application controll script.
#

module LocalPort
  VERSION = "0.1.3"

  class << self
    def invoke(argv)
      begin
        load_config() # to set location of applications
        correct_installed_app() # correct installed applications

        command, args = parse_args(argv)
        command = find_command(command)

        command[:exec].call args
      rescue LocalPort::CommandError => e
        puts "localport: #{e.message}"
      rescue => e
        raise e
      end
    end

    def load_config
      unless File.exist? LocalPort::CONF_FILE
        config.setup
      end
      load LocalPort::CONF_FILE
    end

    def correct_installed_app
      config.installed_app
    end

    def parse_args(args)
      if args.empty?
        puts usage()
        exit 1
      end
      command = args.shift
      [command, args]
    end

    def find_command(name)
      command.find name
    end

    def list_command
      command.list
    end

    def usage
      <<-"USAGE"
Usage:

  #{File.basename $0} command [application_dir] | [--version | --help]

  commands:
    #{command.commands.map do |name, detail|  name + ": " + detail[:description] end.join("\n    ")}
      USAGE
    end
  end
end

if __FILE__ == $0
  LocalPort.invoke(ARGV.dup)
end

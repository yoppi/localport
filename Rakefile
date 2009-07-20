$LOAD_PATH.unshift File.dirname(__FILE__) + "/lib"

require 'rake/clean'
require 'rake/gempackagetask'
require 'localport'

desk "default task"
task :default => [:install]

desk "install task"
task :install => [:package] do
  sh "gem install pkg/#{name}-#{version}.gem"
end

name = "localport"
version = LocalPort::VERSION

spec = Gem::Specification.new do |s|
  s.name = name
  s.version = version
  s.summary = "Local Application management system"
  s.description = "localport is a local application management system"
  s.files = %w{README Rakefile} + Dir["lib/**/*"]
  s.executables = %w{localport}
  s.add_dependency("highline", ">= 1.5.0")
  s.authors = %w{yoppi}
  s.email = "y.hirokazu@gmail.com"
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true
end

task :gemspec do
  filename = "#{name}.gemspec"
  open(filename, 'w') do |f|
    f.write spec.to_ruby
  end
  puts <<-EOS
  Successfully generated gemspec
  Name: #{name}
  Version: #{version}
  File: #{filename}
  EOS
end

CLEAN.include %w{pkg}

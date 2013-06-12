# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'localport'

Gem::Specification.new do |s|
  s.name = "localport"
  s.version = LocalPort::VERSION
  s.authors = ["yoppi"]
  s.email = "y.hirokazu@gmail.com"
  s.date = "2012-11-01"
  s.description = "localport is a local application management system"
  s.summary = "Local Application management system"
  s.homepage = "http://github.com/yoppi/localport"
  s.licenses = ["MIT"]
  s.extra_rdoc_files = ["README.md"]

  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "highline"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
end


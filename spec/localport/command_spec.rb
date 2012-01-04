# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'spec_helper'

describe LocalPort::Command do
  it "should raise CommandError in unknown command" do
    expect { LocalPort.command.find("foo") }.should raise_error(
      LocalPort::CommandError, "foo"
    )
  end

  it "should return command hash in provided command" do
    command = LocalPort.command.find("install")
    command[:name].should == 'install'
  end
end


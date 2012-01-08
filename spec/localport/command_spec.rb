# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'spec_helper'

describe LocalPort::Command do
  it "should raise CommandError in unknown command" do
    expect { LocalPort.command.find("foo") }.to raise_error(
      LocalPort::CommandError
    )
  end

  it "should return command hash in provided command" do
    command = LocalPort.command.find("install")
    command[:name].should == 'install'
  end
end

describe LocalPort::Command, "#install" do
  context "path is emtpy" do
    it "should raise CommandError in no args" do
      command = LocalPort.command.find("install")
      expect { command[:exec].call([]) }.to raise_error(
        LocalPort::CommandError
      )
    end
  end
end

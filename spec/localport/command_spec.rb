# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'spec_helper'

require 'fileutils'

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

  context "install .exe file in cygwin" do
    let(:bin) { File.join(File.dirname(__FILE__), "test/test-0.0.0/bin/test.exe") }
    let(:app) { File.join(File.dirname(__FILE__), "test/test-0.0.0") }
    let(:symlink) { File.join(File.dirname(__FILE__), "test-0.0.0.exe") }
    let(:install) { LocalPort.command.find("install") }

    before do
      FileUtils.mkdir_p(File.dirname(bin))
      FileUtils.touch(bin)
      LocalPort::LINK_DIR = File.dirname(__FILE__)
    end

    it "should have .exe in symbolic" do
      install[:exec].call([app])
      File.exist?(symlink).should be_true
    end

    after do
      FileUtils.rm_rf(File.join(File.dirname(__FILE__), "test"))
      FileUtils.rm(symlink)
    end
  end
end

describe LocalPort::Command, "#activate" do
  context "activate with no app" do
    it "should raise CommandError" do
      command = LocalPort.command.find("activate")
      expect { command[:exec].call([]) }.to raise_error(
        LocalPort::CommandError
      )
    end
  end
end

describe LocalPort::Command, "#deactivate" do
  context "deactivate with no args" do
    it "should raise CommandError" do
      command = LocalPort.command.find("deactivate")
      expect { command[:exec].call([]) }.to raise_error(
        LocalPort::CommandError
      )
    end
  end
end

describe LocalPort::Command do
  it "should get command list" do
    LocalPort.command.list.sort.should == %w[activate deactivate install installed uninstall]
  end
end

# coding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'spec_helper'

require 'fileutils'

LocalPort::LINK_DIR = File.dirname(__FILE__)
LocalPort::APPS_DIR = File.dirname(__FILE__)

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

  let(:install) { LocalPort.command.find("install") }

  context "path is emtpy" do
    it "should raise CommandError in no args" do
      command = LocalPort.command.find("install")
      expect { command[:exec].call([]) }.to raise_error(
        LocalPort::CommandError
      )
    end
  end

  context "install .exe file in cygwin" do
    let(:bin) { File.join(File.dirname(__FILE__), "test/0.0.0/bin/test.exe") }
    let(:app) { File.join(File.dirname(__FILE__), "test/0.0.0") }
    let(:symlink) { File.join(File.dirname(__FILE__), "test-0.0.0.exe") }

    before do
      FileUtils.mkdir_p(File.dirname(bin))
      FileUtils.touch(bin)
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

  context "install has *sbin* directory application" do
    let(:sbin) { File.join(File.dirname(__FILE__), "test/0.0.0/sbin/a") }
    let(:app) { File.join(File.dirname(__FILE__), "test/0.0.0") }
    let(:symlink) { File.join(File.dirname(__FILE__), "a-0.0.0") }

    before do
      FileUtils.mkdir_p(File.dirname(sbin))
      FileUtils.touch(sbin)
    end

    it "should install sbin file" do
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

describe LocalPort::Command, "#update" do
  let(:update) { LocalPort.command.find("update") }

  it "should exist command" do
    LocalPort.command.find("update").should_not be_nil
  end

  context "update one" do
    let(:app) { File.join(File.dirname(__FILE__), "test/0.0.0") }
    let(:bin) { File.join(File.dirname(__FILE__), "test/0.0.0/bin/a") }
    let(:bin_new) { File.join(File.dirname(__FILE__), "test/0.0.0/bin/b") }
    let(:symlink) { File.join(File.dirname(__FILE__), "a-0.0.0") }
    let(:symlink_app) { File.join(File.dirname(__FILE__), "a") }
    let(:symlink_new) { File.join(File.dirname(__FILE__), "b-0.0.0") }
    let(:symlink_new_app) { File.join(File.dirname(__FILE__), "b") }

    before do
      FileUtils.mkdir_p(File.dirname(bin))
      FileUtils.touch(bin)
      File.symlink(bin, symlink)
    end

    it "should update specifed application" do
      FileUtils.touch(bin_new)
      config.installed_app()
      update[:exec].call(["test"])
      File.exists? symlink_new
      File.exists? symlink_new_app
    end

    after do
      FileUtils.rm_rf(File.join(File.dirname(__FILE__), "test"))
      FileUtils.rm([symlink, symlink_new, symlink_app, symlink_new_app])
    end
  end
end

describe LocalPort::Command do
  it "should get command list" do
    LocalPort.command.list.sort.should == %w[activate deactivate install installed uninstall update]
  end
end

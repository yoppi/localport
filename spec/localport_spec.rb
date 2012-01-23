# coding: utf-8

$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe LocalPort do
  context "executed in no args" do
    it "should show usage and exit status is 1" do
      expect { LocalPort.parse_args([]) }.to exit_with_code(1)
    end
  end
end

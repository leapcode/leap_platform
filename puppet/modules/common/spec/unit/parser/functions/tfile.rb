#! /usr/bin/env ruby

require File.dirname(__FILE__) + '/../../../spec_helper'
require 'mocha'

describe "the tfile function" do

  before :each do
    @scope = Puppet::Parser::Scope.new
  end

  it "should exist" do
    Puppet::Parser::Functions.function("tfile").should == "function_tfile"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    lambda { @scope.function_tfile([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if there is more than 1 arguments" do
    lambda { @scope.function_tfile(["bar", "gazonk"]) }.should( raise_error(Puppet::ParseError))
  end

  describe "when executed properly" do

    before :each do
       File.stubs(:read).with('/some_path/aa').returns("foo1\nfoo2\n")
    end

    it "should return the content of the file" do
      File.stubs(:exists?).with('/some_path/aa').returns(true)
      result = @scope.function_tfile(['/some_path/aa'])
      result.should == "foo1\nfoo2\n"
    end

    it "should touch a file if it does not exist" do
      File.stubs(:exists?).with('/some_path/aa').returns(false)
      File.stubs(:directory?).with('/some_path').returns(true)
      FileUtils.expects(:touch).with('/some_path/aa')
      result = @scope.function_tfile(['/some_path/aa'])
      result.should == "foo1\nfoo2\n"
    end

    it "should create the path if it does not exist" do
      File.stubs(:exists?).with('/some_path/aa').returns(false)
      File.stubs(:directory?).with('/some_path').returns(false)
      FileUtils.expects(:mkdir_p).with("/some_path",:mode => 0700)
      FileUtils.expects(:touch).with('/some_path/aa')
      result = @scope.function_tfile(['/some_path/aa'])
      result.should == "foo1\nfoo2\n"
    end
  end

end

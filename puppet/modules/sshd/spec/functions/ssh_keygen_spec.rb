#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'rspec-puppet'
require 'mocha'
require 'fileutils'

describe 'ssh_keygen' do

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should exist' do
    Puppet::Parser::Functions.function("ssh_keygen").should == "function_ssh_keygen"
  end

  it 'should raise a ParseError if no argument is passed' do
    lambda {
      scope.function_ssh_keygen([])
    }.should(raise_error(Puppet::ParseError))
  end

  it 'should raise a ParseError if there is more than 1 arguments' do
    lambda {
      scope.function_ssh_keygen(["foo", "bar"])
    }.should( raise_error(Puppet::ParseError))
  end

  it 'should raise a ParseError if the argument is not fully qualified' do
    lambda {
      scope.function_ssh_keygen(["foo"])
    }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if the private key path is a directory" do
    File.stubs(:directory?).with("/some_dir").returns(true)
    lambda {
      scope.function_ssh_keygen(["/some_dir"])
    }.should( raise_error(Puppet::ParseError))
  end

  it "should raise a ParseError if the public key path is a directory" do
    File.stubs(:directory?).with("/some_dir.pub").returns(true)
    lambda {
      scope.function_ssh_keygen(["/some_dir.pub"])
    }.should( raise_error(Puppet::ParseError))
  end

  describe 'when executing properly' do
    before do
      File.stubs(:directory?).with('/tmp/a/b/c').returns(false)
      File.stubs(:directory?).with('/tmp/a/b/c.pub').returns(false)
      File.stubs(:read).with('/tmp/a/b/c').returns('privatekey')
      File.stubs(:read).with('/tmp/a/b/c.pub').returns('publickey')
    end

    it 'should fail if the public but not the private key exists' do
      File.stubs(:exists?).with('/tmp/a/b/c').returns(true)
      File.stubs(:exists?).with('/tmp/a/b/c.pub').returns(false)
      lambda {
        scope.function_ssh_keygen(['/tmp/a/b/c'])
      }.should( raise_error(Puppet::ParseError))
    end

    it "should fail if the private but not the public key exists" do
      File.stubs(:exists?).with("/tmp/a/b/c").returns(false)
      File.stubs(:exists?).with("/tmp/a/b/c.pub").returns(true)
      lambda {
        scope.function_ssh_keygen(["/tmp/a/b/c"])
      }.should( raise_error(Puppet::ParseError))
    end


    it "should return an array of size 2 with the right conent if the keyfiles exists" do
      File.stubs(:exists?).with("/tmp/a/b/c").returns(true)
      File.stubs(:exists?).with("/tmp/a/b/c.pub").returns(true)
      File.stubs(:directory?).with('/tmp/a/b').returns(true)
      Puppet::Util.expects(:execute).never
      result = scope.function_ssh_keygen(['/tmp/a/b/c'])
      result.length.should == 2
      result[0].should == 'privatekey'
      result[1].should == 'publickey'
    end

    it "should create the directory path if it does not exist" do
      File.stubs(:exists?).with("/tmp/a/b/c").returns(false)
      File.stubs(:exists?).with("/tmp/a/b/c.pub").returns(false)
      File.stubs(:directory?).with("/tmp/a/b").returns(false)
      FileUtils.expects(:mkdir_p).with("/tmp/a/b", :mode => 0700)
      Puppet::Util::Execution.expects(:execute).returns("")
      result = scope.function_ssh_keygen(['/tmp/a/b/c'])
      result.length.should == 2
      result[0].should == 'privatekey'
      result[1].should == 'publickey'
    end

    it "should generate the key if the keyfiles do not exist" do
      File.stubs(:exists?).with("/tmp/a/b/c").returns(false)
      File.stubs(:exists?).with("/tmp/a/b/c.pub").returns(false)
      File.stubs(:directory?).with("/tmp/a/b").returns(true)
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/ssh-keygen','-t', 'rsa', '-b', '4096', '-f', '/tmp/a/b/c', '-P', '', '-q']).returns("")
      result = scope.function_ssh_keygen(['/tmp/a/b/c'])
      result.length.should == 2
      result[0].should == 'privatekey'
      result[1].should == 'publickey'
    end

    it "should fail if something goes wrong during generation" do
      File.stubs(:exists?).with("/tmp/a/b/c").returns(false)
      File.stubs(:exists?).with("/tmp/a/b/c.pub").returns(false)
      File.stubs(:directory?).with("/tmp/a/b").returns(true)
      Puppet::Util::Execution.expects(:execute).with(['/usr/bin/ssh-keygen','-t', 'rsa', '-b', '4096', '-f', '/tmp/a/b/c', '-P', '', '-q']).returns("something is wrong")
      lambda {
        scope.function_ssh_keygen(["/tmp/a/b/c"])
      }.should( raise_error(Puppet::ParseError))
    end
  end
end

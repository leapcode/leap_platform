require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'guess_apache_version function' do

  #let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    expect(Puppet::Parser::Functions.function("guess_apache_version")).to eq("function_guess_apache_version")
  end

  context 'on debian 7.8' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '7.8'
      }
    end
    it "should return 2.2" do
      result = scope.function_guess_apache_version([])
      expect(result).to(eq('2.2'))
    end
  end

  context 'on debian 8.0' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '8.0'
      }
    end
    it "should return 2.4" do
      result = scope.function_guess_apache_version([])
      expect(result).to(eq('2.4'))
    end
  end

  context 'on ubuntu 15.10' do
    let(:facts) do
      {
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '15.10'
      }
    end
    it "should return 2.4" do
      result = scope.function_guess_apache_version([])
      expect(result).to(eq('2.4'))
    end
  end

end

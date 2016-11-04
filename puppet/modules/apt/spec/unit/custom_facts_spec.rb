require "spec_helper"

describe "Facter::Util::Fact" do
  before {
    Facter.clear
  }

  describe 'custom facts' do

    context 'Debian 7' do
      before do
        Facter.fact(:operatingsystem).stubs(:value).returns("Debian")
        Facter.fact(:operatingsystemrelease).stubs(:value).returns("7.8")
        Facter.fact(:lsbdistcodename).stubs(:value).returns("wheezy")
      end

      it "debian_release = oldstable" do
        expect(Facter.fact(:debian_release).value).to eq('oldstable')
      end

      it "debian_codename = wheezy" do
        expect(Facter.fact(:debian_codename).value).to eq('wheezy')
      end

      it "debian_nextcodename = jessie" do
        expect(Facter.fact(:debian_nextcodename).value).to eq('jessie')
      end

      it "debian_nextrelease = stable" do
        expect(Facter.fact(:debian_nextrelease).value).to eq('stable')
      end
    end

    context 'Debian 8' do
      before do
        Facter.fact(:operatingsystem).stubs(:value).returns("Debian")
        Facter.fact(:operatingsystemrelease).stubs(:value).returns("8.0")
        Facter.fact(:lsbdistcodename).stubs(:value).returns("jessie")
      end

      it "debian_release = stable" do
        expect(Facter.fact(:debian_release).value).to eq('stable')
      end

      it "debian_codename = jessie" do
        expect(Facter.fact(:debian_codename).value).to eq('jessie')
      end

      it "debian_nextcodename = stretch" do
        expect(Facter.fact(:debian_nextcodename).value).to eq('stretch')
      end

      it "debian_nextrelease = testing" do
        expect(Facter.fact(:debian_nextrelease).value).to eq('testing')
      end
    end

    context 'Ubuntu 15.10' do
      before do
        Facter.fact(:operatingsystem).stubs(:value).returns("Ubuntu")
        Facter.fact(:operatingsystemrelease).stubs(:value).returns("15.10")
        Facter.fact(:lsbdistcodename).stubs(:value).returns("wily")
      end

      it "ubuntu_codename = wily" do
        expect(Facter.fact(:ubuntu_codename).value).to eq('wily')
      end

      it "ubuntu_nextcodename = xenial" do
        expect(Facter.fact(:ubuntu_nextcodename).value).to eq('xenial')
      end
    end
  end

  describe "Test 'apt_running' fact" do
    it "should return true when apt-get is running" do
      Facter::Util::Resolution.stubs(:exec).with("pgrep apt-get >/dev/null 2>&1 && echo true || echo false").returns("true")
      expect(Facter.fact(:apt_running).value).to eq('true')
    end
    it "should return false when apt-get is not running" do
      Facter::Util::Resolution.stubs(:exec).with("pgrep apt-get >/dev/null 2>&1 && echo true || echo false").returns("false")
      expect(Facter.fact(:apt_running).value).to eq('false')
    end
  end

end

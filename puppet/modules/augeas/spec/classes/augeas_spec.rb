require 'spec_helper'

describe 'augeas' do

  context 'when on an unsupported Operating System' do
    let (:facts) do
      {
        :osfamily => 'MS-DOS',
      }
    end

    it 'should fail' do
      expect { is_expected.to contain_package('ruby-augeas') }.to raise_error(Puppet::Error, /Unsupported OS family/)
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'without params' do
        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_package('libaugeas0').with(
            :ensure => 'present'
          ) }
          it { is_expected.to contain_package('augeas-tools').with(
            :ensure => 'present'
          ) }
          it { is_expected.to contain_package('augeas-lenses').with(
            :ensure => 'present'
          ) }
          case facts[:lsbdistcodename]
          when 'squeeze', 'lucid', 'precise'
            it { is_expected.to contain_package('ruby-augeas').with(
              :ensure => 'present',
              :name   => 'libaugeas-ruby1.8'
            ) }
          else
            it { is_expected.to contain_package('ruby-augeas').with(
              :ensure => 'present',
              :name   => 'libaugeas-ruby1.9.1'
            ) }
          end
        when 'RedHat'
          it { is_expected.to contain_package('augeas').with(
            :ensure => 'present'
          ) }
          it { is_expected.to contain_package('augeas-libs').with(
            :ensure => 'present'
          ) }
          it { is_expected.to contain_package('ruby-augeas').with(
            :ensure => 'present',
            :name   => 'ruby-augeas'
          ) }
        end
        it { is_expected.to contain_file('/usr/share/augeas/lenses').with(
          :ensure       => 'directory',
          :purge        => 'true',
          :force        => 'true',
          :recurse      => 'true',
          :recurselimit => 1
        ) }
        it { is_expected.to contain_file('/usr/share/augeas/lenses/dist').with(
          :ensure       => 'directory',
          :purge        => 'false'
        ) }
        it { is_expected.to contain_file('/usr/share/augeas/lenses/tests').with(
          :ensure       => 'directory',
          :purge        => 'true',
          :force        => 'true'
        ).without(:recurse) }
      end

      context 'when versions are specified' do
        let (:params) do
          {
            :version      => '1.2.3',
            :ruby_version => '3.2.1',
          }
        end

        case facts[:osfamily]
        when 'Debian'
          it { is_expected.to contain_package('libaugeas0').with(
            :ensure => '1.2.3'
          ) }
          it { is_expected.to contain_package('augeas-tools').with(
            :ensure => '1.2.3'
          ) }
          it { is_expected.to contain_package('augeas-lenses').with(
            :ensure => '1.2.3'
          ) }
          case facts[:lsbdistcodename]
          when 'squeeze', 'lucid', 'precise'
            it { is_expected.to contain_package('ruby-augeas').with(
              :ensure => '3.2.1',
              :name   => 'libaugeas-ruby1.8'
            ) }
          else
            it { is_expected.to contain_package('ruby-augeas').with(
              :ensure => '3.2.1',
              :name   => 'libaugeas-ruby1.9.1'
            ) }
          end
        when 'RedHat'
          it { is_expected.to contain_package('augeas').with(
            :ensure => '1.2.3'
          ) }
          it { is_expected.to contain_package('augeas-libs').with(
            :ensure => '1.2.3'
          ) }
          it { is_expected.to contain_package('ruby-augeas').with(
            :ensure => '3.2.1',
            :name   => 'ruby-augeas'
          ) }
        end

      end

      context 'with a non standard lens_dir' do
        let (:params) do
          {
            :lens_dir => '/opt/augeas/lenses',
          }
        end

        it { is_expected.to contain_file('/opt/augeas/lenses').with(
          :ensure       => 'directory',
          :purge        => 'true',
          :force        => 'true',
          :recurse      => 'true',
          :recurselimit => 1
        ) }
        it { is_expected.to contain_file('/opt/augeas/lenses/dist').with(
          :ensure       => 'directory',
          :purge        => 'false'
        ) }
        it { is_expected.to contain_file('/opt/augeas/lenses/tests').with(
          :ensure       => 'directory',
          :purge        => 'true',
          :force        => 'true'
        ).without(:recurse) }
      end
    end
  end
end

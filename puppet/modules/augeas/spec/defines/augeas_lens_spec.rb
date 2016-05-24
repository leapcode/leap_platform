require 'spec_helper'

describe 'augeas::lens' do
  let (:title) { 'foo' }

  context 'when not declaring augeas class first' do
    let (:params) do
      {
        :lens_source => '/tmp/foo.aug',
      }
    end

    it 'should error' do
      expect {
        is_expected.to contain_file('/usr/share/augeas/lenses/foo.aug')
      }.to raise_error(Puppet::Error, /You must declare the augeas class/)
    end
  end

  context 'when declaring augeas class first' do

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :augeasversion => :undef,
          })
        end

        context 'With standard augeas version' do

          let(:pre_condition) do
            "class { '::augeas': }"
          end

          context 'when no lens_source is passed' do
            it 'should error' do
              expect {
                is_expected.to contain_file('/usr/share/augeas/lenses/foo.aug')
              }.to raise_error(Puppet::Error, /Must pass lens_source/)
            end
          end

          context 'when lens_source is passed' do
            let (:params) do
              {
                :lens_source => '/tmp/foo.aug',
              }
            end

            it { is_expected.to contain_file('/usr/share/augeas/lenses/foo.aug') }
            it { is_expected.to contain_exec('Typecheck lens foo') }
            it { is_expected.not_to contain_file('/usr/share/augeas/lenses/tests/test_foo.aug') }
            it { is_expected.not_to contain_exec('Test lens foo') }
          end

          context 'when lens_source and test_source are passed' do
            let (:params) do
              {
                :lens_source => '/tmp/foo.aug',
                :test_source => '/tmp/test_foo.aug',
              }
            end

            it { is_expected.to contain_file('/usr/share/augeas/lenses/foo.aug') }
            it { is_expected.to contain_exec('Typecheck lens foo') }
            it { is_expected.to contain_file('/usr/share/augeas/lenses/tests/test_foo.aug') }
            it { is_expected.to contain_exec('Test lens foo') }
          end
        end

        context 'when stock_since is passed and augeas is older' do
          let (:params) do
            {
              :lens_source => '/tmp/foo.aug',
              :stock_since => '1.2.3',
            }
          end

          let(:pre_condition) do
            "class { '::augeas': version => '1.0.0' }"
          end

          it { is_expected.to contain_file('/usr/share/augeas/lenses/foo.aug') }
          it { is_expected.to contain_exec('Typecheck lens foo') }
        end

        context 'when stock_since is passed and augeas is newer' do
          let (:params) do
            {
              :lens_source => '/tmp/foo.aug',
              :stock_since => '1.2.3',
            }
          end

          let(:pre_condition) do
            "class { '::augeas': version => '1.3.0' }"
          end

          it do
            pending "undefined method `negative_failure_message'"
            is_expected.not_to contain_file('/usr/share/augeas/lenses/foo.aug')
          end
          it do
            pending "undefined method `negative_failure_message'"
            is_expected.not_to contain_exec('Typecheck lens foo')
          end
        end
      end
    end
  end
end

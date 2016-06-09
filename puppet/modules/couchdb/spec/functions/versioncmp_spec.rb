require 'spec_helper'

describe 'versioncmp' do
    it { should run.with_params('7.2','8').and_return(-1) }
    it { should run.with_params('7','8').and_return(-1) }
    it { should run.with_params('8','8').and_return(0) }
    it { should run.with_params('8.1','8').and_return(1) }
end


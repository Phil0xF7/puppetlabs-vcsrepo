require 'spec_helper_acceptance'

describe 'basic tests' do
  it 'copied the module' do
    shell('ls /etc/puppet/modules/vcsrepo/Modulefile', {:acceptable_exit_codes => 0})
  end
end

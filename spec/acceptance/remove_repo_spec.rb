require 'spec_helper_acceptance'

describe 'remove a repo' do
  it 'creates a blank repo' do
    pp = <<-EOS
    vcsrepo { '/tmp/testrepo_deleted':
      ensure => present,
      provider => git,
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'removes a repo' do
    pp = <<-EOS
    vcsrepo { '/tmp/testrepo_deleted':
      ensure => absent,
      provider => git,
    }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  describe file('/tmp/testrepo_deleted') do
    it { should_not be_directory }
  end
end

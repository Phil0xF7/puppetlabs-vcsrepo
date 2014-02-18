require 'spec_helper_acceptance'

describe "clones a remote repo" do
  context "clones a remote repo - master" do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/vcsrepo_default':
        ensure => present,
        provider => git,
        source => 'https://github.com/puppetlabs/puppetlabs-vcsrepo.git',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/vcsrepo_default') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_default/.git') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_default/.git/HEAD') do
      it { should contain 'ref: refs/heads/master' }
    end
  end

  context 'clone a remote repo based on a commit SHA' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/vcsrepo_sha':
        ensure => present,
        provider => git,
        source => 'https://github.com/puppetlabs/puppetlabs-vcsrepo.git',
        revision => 'f252283cf1501960f627e121d852b05f67c7214c',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/vcsrepo_sha') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_sha/.git') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_sha/.git/HEAD') do
      it { should contain 'f252283cf1501960f627e121d852b05f67c7214c' }
    end
  end

  context 'clone a remote repo based on a tag' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/vcsrepo_tag':
        ensure => present,
        provider => git,
        source => 'https://github.com/puppetlabs/puppetlabs-vcsrepo.git',
        revision => '0.1.2',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/vcsrepo_tag') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_tag/.git') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_tag/.git/HEAD') do
      it { should contain 'efe313070c0aa56a67f3c393889334c2f4fe2998' }
    end
  end

  context 'clone a remote repo based on a branch name' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/vcsrepo_branch':
        ensure => present,
        provider => git,
        source => 'https://github.com/puppetlabs/puppetlabs-vcsrepo.git',
        revision => 'feature/hg',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/vcsrepo_branch') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_branch/.git') do
      it { should be_directory }
    end

    describe file('/tmp/vcsrepo_branch/.git/HEAD') do
      it { should contain 'ref: refs/heads/feature/hg' }
    end
  end
end

require 'spec_helper_acceptance'

describe "clones a remote repo" do
  context "clones a remote repo - master" do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/testrepo') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo/.git') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo/.git/HEAD') do
      it { should contain 'ref: refs/heads/master' }
    end
  end

  context 'clone a remote repo based on a commit SHA' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_sha':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        revision => '32a7bfcdae539abb2cf77365edbaa250d592237b',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/testrepo_sha') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_sha/.git') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_sha/.git/HEAD') do
      it { should contain '32a7bfcdae539abb2cf77365edbaa250d592237b' }
    end
  end

  context 'clone a remote repo based on a tag' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_tag':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        revision => '0.0.1',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/testrepo_tag') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_tag/.git') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_tag/.git/HEAD') do
      it { should contain 'aaceb4dbbae2850b8669d6c249f0532d3be7f1b1' }
    end
  end

  context 'clone a remote repo based on a branch name' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_branch':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        revision => 'a_branch',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/testrepo_branch') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_branch/.git') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_branch/.git/HEAD') do
      it { should contain 'ref: refs/heads/a_branch' }
    end
  end
end

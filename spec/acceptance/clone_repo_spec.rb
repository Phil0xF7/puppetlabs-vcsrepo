require 'spec_helper_acceptance'

describe 'clones a remote repo' do
  context 'get the current master HEAD' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/testrepo/.git') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo/.git/HEAD') do
      it { should contain 'ref: refs/heads/master' }
    end
  end

  context 'using a commit SHA' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_sha':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        revision => '32a7bfcdae539abb2cf77365edbaa250d592237b',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/testrepo_sha/.git') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_sha/.git/HEAD') do
      it { should contain '32a7bfcdae539abb2cf77365edbaa250d592237b' }
    end
  end

  context 'using a tag' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_tag':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        revision => '0.0.1',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/testrepo_tag/.git') do
      it { should be_directory }
    end

    it 'should have the tag as the HEAD' do
      shell('git --git-dir=/tmp/testrepo_tag/.git name-rev HEAD | grep "0.0.1"')
    end
  end

  context 'using a branch name' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_branch':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        revision => 'a_branch',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/testrepo_branch/.git') do
      it { should be_directory }
    end

    describe file('/tmp/testrepo_branch/.git/HEAD') do
      it { should contain 'ref: refs/heads/a_branch' }
    end
  end

  context 'ensure latest' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_latest':
        ensure => latest,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        revision => 'master',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'verifies the HEAD commit SHA on remote and local match' do
      remote_commit = shell('git ls-remote file:///tmp/testrepo_latest HEAD | head -1').stdout
      local_commit = shell('git --git-dir=/tmp/testrepo_latest/.git rev-parse HEAD').stdout.chomp
      remote_commit.should include(local_commit)
    end
  end

  context 'with shallow clone' do
    it 'does a shallow clone' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_shallow':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        depth => '1',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/testrepo_shallow/.git/shallow') do
      it { should be_file }
    end
  end

  context 'path is not empty and not a repository' do
    before(:all) do
      shell('mkdir /tmp/not_a_repo', :acceptable_exit_codes => [0,1])
      shell('touch /tmp/not_a_repo/file1.txt', :acceptable_exit_codes => [0,1])
    end

    it 'should raise an exception' do
      pp = <<-EOS
      vcsrepo { '/tmp/not_a_repo':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
      }
      EOS
      apply_manifest(pp, :expect_failures => true)
    end
  end

  context 'with an owner' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_owner':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        owner => 'vagrant',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have "vagrant" user permissions on all files/folders' do
      shell('stat -c %U $(find /tmp/testrepo_owner) | uniq | wc -l | grep 1')
      shell('stat -c %U $(find /tmp/testrepo_owner) | uniq | grep "vagrant"')
    end
  end

  context 'with a group' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_group':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        group => 'vagrant',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have "vagrant" group permissions on all files/folders' do
      shell('stat -c %G $(find /tmp/testrepo_group) | uniq | wc -l | grep 1')
      shell('stat -c %G $(find /tmp/testrepo_group) | uniq | grep "vagrant"')
    end
  end

  context 'with excludes' do
    it 'clones a repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_excludes':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        excludes => ['exclude1.txt', 'exclude2.txt'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/testrepo_excludes/.git/info/exclude') do
      its(:content) { should match /exclude1.txt/ }
      its(:content) { should match /exclude2.txt/ }
    end
  end

  context 'with force' do
    before(:all) do
      shell('mkdir -p /tmp/testrepo_force/folder')
      shell('touch /tmp/testrepo_force/temp.txt')
    end

    it 'applys the manifest' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_force':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        force => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/tmp/testrepo_force/folder') do
      it { should_not be_directory }
    end

    describe file('/tmp/testrepo_force/temp.txt') do
      it { should_not be_file }
    end

    describe file('/tmp/testrepo_force/.git') do
      it { should be_directory }
    end
  end

  context 'as a user' do
    it 'applys the manifest' do
      pp = <<-EOS
      user { 'testuser':
        ensure => present,
      }

      vcsrepo { '/tmp/testrepo_user':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        user => 'testuser',
        require => User['testuser'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should have "testuser" user permissions on all files/folders' do
      shell('stat -c %U $(find /tmp/testrepo_user) | uniq | wc -l | grep 1')
      shell('stat -c %U $(find /tmp/testrepo_user) | uniq | grep "testuser"')
    end

    it 'should have "testuser" group permissions on all files/folders' do
      shell('stat -c %G $(find /tmp/testrepo_user) | uniq | wc -l | grep 1')
      shell('stat -c %G $(find /tmp/testrepo_user) | uniq | grep "testuser"')
    end
  end

  context 'non-origin remote name' do
    it 'applys the manifest' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_remote':
        ensure => present,
        provider => git,
        source => 'file:///tmp/testrepo.git',
        remote => 'testorigin',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'remote name is "testorigin"' do
      shell('git --git-dir=/tmp/testrepo_remote/.git remote | grep "testorigin"')
    end
  end
end

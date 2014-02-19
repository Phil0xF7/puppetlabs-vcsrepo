require 'spec_helper_acceptance'

describe 'create a repo' do
  context 'create a blank repo' do
    it 'creates a blank repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_blank_repo':
        ensure => present,
        provider => git,
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file("/tmp/testrepo_blank_repo/") do
      it 'should have zero files' do
        shell('ls -1 /tmp/testrepo_blank_repo | wc -l') do |r|
          expect(r.stdout).to match(/0\n/)
        end
      end
    end

    describe file('/tmp/testrepo_blank_repo/.git') do
      it { should be_directory }
    end

  end

  context 'create a bare repo' do
    it 'create a bare repo' do
      pp = <<-EOS
      vcsrepo { '/tmp/testrepo_bare_repo':
        ensure => bare,
        provider => git,
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/tmp/testrepo_bare_repo/config') do
      it { should contain 'bare = true' }
    end

    describe file('/tmp/testrepo_bare_repo/.git') do
      it { should_not be_directory }
    end
  end
end

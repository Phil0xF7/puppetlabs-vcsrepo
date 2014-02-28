require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'vcsrepo')
    shell('yum install -y git')

    # copy and untar test git repo
    #scp_to(master, "#{proj_root}/spec/acceptance/files/testrepo.tar.gz", '/tmp')
    #shell("tar xvf /tmp/testrepo.tar.gz -C /tmp")
    run_script("#{proj_root}/spec/acceptance/files/create_git_repo.sh")

    shell('/bin/touch /etc/puppet/hiera.yaml')
  end
end

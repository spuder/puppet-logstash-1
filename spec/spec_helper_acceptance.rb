require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Install Puppet
  puppetversion = ENV['VM_PUPPET_VERSION']
  install_package host, 'rubygems'
  on host, "gem install puppet --no-ri --no-rdoc --version '~> #{puppetversion}'"
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'logstash')
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib', '-v 2.3.0'), { :acceptable_exit_codes => [0,1] }
      if fact('osfamily') == 'Debian'
        on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      end
    end
  end
end

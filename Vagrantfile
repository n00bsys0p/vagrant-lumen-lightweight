# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

cur_dir     = File.dirname(File.expand_path(__FILE__))
app_config  = YAML.load_file("#{cur_dir}/app.yaml")
core_config = YAML.load_file("#{cur_dir}/config.yaml")

Vagrant.configure(2) do |config|
  config.vm.box = "puppetlabs/debian-7.8-64-puppet"

  config.vm.synced_folder "www", core_config[:web_root]

  config.vm.network "forwarded_port", guest: 80, host: app_config[:local_port]

  config.vm.provision "puppet" do |puppet|
    puppet.facter = {
      'lumen_version'        => '~1.0',
      'lumen_app_name'       => app_config[:application][:name],
      'lumen_app_db_enabled' => app_config[:application][:db_enabled],
      'web_user'             => core_config[:web_user],
      'web_group'            => core_config[:web_group],
      'web_root'             => core_config[:web_root]
    }

    puppet.hiera_config_path = 'puppet/hiera.yaml'
    puppet.module_path = 'puppet/modules'
    puppet.manifests_path = 'puppet/manifests'
    puppet.manifest_file = 'site.pp'
    # puppet.options = '--verbose --debug'
  end
end

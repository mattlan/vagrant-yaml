# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# constants
DEFAULT_PROVIDER = 'virtualbox'
DEFAULT_CPU = 2
DEFAULT_MEMORY = 1024

# load yaml config
current_dir = File.dirname(File.expand_path(__FILE__))
cfg         = YAML.load_file("#{current_dir}/config.yaml")

# initialize vagrant
# https://www.vagrantup.com/docs/
Vagrant.configure("#{cfg['vagrant']['api_version']}") do |config|
  # begin loop of each machine in config.yaml
  Array(cfg['machines']).each do |vm|

    # begin vm config definition
    config.vm.define vm['hostname'] do |host|
      # handle vm details
      # https://www.vagrantup.com/docs/multi-machine/
      host.vm.box                 = vm['box']
      host.vm.hostname            = vm['hostname']

      # handle vm provider config
      # https://www.vagrantup.com/docs/providers/configuration.html
      provider = vm['provider'] || DEFAULT_PROVIDER

      host.vm.provider provider do |v|
        v.name                    = vm['hostname']
        v.cpus                    = vm['cpus'] || DEFAULT_CPU
        v.memory                  = vm['memory'] || DEFAULT_MEMORY

        # handle arbitrary vm cpu execution cap if specified
        # https://www.vagrantup.com/docs/virtualbox/configuration.html
        if !vm['cpuexecutioncap'].nil?
          v.customize               ['modifyvm', :id, '--cpuexecutioncap', "#{vm['cpuexecutioncap']}"]
        end

        # handle arbitrary vm custom config if specified
        # https://www.vagrantup.com/docs/virtualbox/configuration.html
        if !vm['customize'].nil?
          Array(vm['customize']).each do |custom|
            temp = Array.new

            # loop through custom array starting at last item and unshift (append as first item) to temp array
            custom.reverse.each do |c|
              temp.unshift(c)
            end

            # temp will be the arbitrary vm customization, unshift required vagrant values to be first in array
            temp.unshift('modifyvm', :id)

            # temp should render as ['modifyvm', :id, 'arg', '...', '...']
            v.customize           temp
          end
        end
      end

      # handle vm network config if specified
      # https://www.vagrantup.com/docs/networking/private_network.html
      Array(vm['network']).each do |net|
        # handle virtualbox provider networking
        if provider == 'virtualbox'
          if !net['ip'].nil?
            # handle dhcp interface
            if net['ip'] == 'dhcp'
              host.vm.network     net['type'], virtualbox__intnet: net['network'], type: net['ip'],
                                  auto_config: net['auto_config'], :mac => net['mac']
            # handle static ip interface
            else
              addr = String(net['ip']).split('/')[0]
              mask = String(net['ip']).split('/')[1]

              host.vm.network     net['type'], virtualbox__intnet: net['network'], ip: addr, netmask: mask,
                                  auto_config: net['auto_config'], :mac => net['mac']
            end
          # handle generic interface
          else
            host.vm.network       net['type'], virtualbox__intnet: net['network'],
                                  auto_config: net['auto_config'], :mac => net['mac']
          end
        # handle non-virtualbox provider networking
        else
          if !net['ip'].nil?
            # handle dhcp interface
            if net['ip'] == 'dhcp'
              host.vm.network     net['type'], type: net['ip'], auto_config: net['auto_config'], :mac => net['mac']
            # handle static ip interface
            else
              addr = String(net['ip']).split('/')[0]
              mask = String(net['ip']).split('/')[1]

              host.vm.network     net['type'], ip: addr, netmask: mask, auto_config: net['auto_config'], :mac => net['mac']
            end
          # handle generic interface
          else
            host.vm.network       net['type'], auto_config: net['auto_config'], :mac => net['mac']
          end
        end
      end

      # handle vm synced folders if specified
      # https://www.vagrantup.com/docs/synced-folders/basic_usage.html
      Array(vm['synced_folders']).each do |folder|
        host.vm.synced_folder     folder['source'], folder['destination']
      end

      # handle vm forwarded ports if specified
      # https://www.vagrantup.com/docs/networking/forwarded_ports.html
      Array(vm['forwarded_ports']).each do |port|
        host.vm.network           'forwarded_port', guest: port['guest'], host: port['host']
      end

      # handle vm inline shell provision if specified
      # https://www.vagrantup.com/docs/provisioning/shell.html
      if !vm['inline'].nil?
        host.vm.provision :shell, inline: vm['inline']
      end

      # handle vm salt provision if specified
      # https://www.vagrantup.com/docs/provisioning/salt.html
      if !vm['salt'].nil?
        host.vm.provision :salt do |salt|
          salt.install_type       = vm['salt']['install_type']
          salt.version            = vm['salt']['version']
          salt.bootstrap_options  = "-x python#{vm['salt']['python_version']}"
          salt.minion_config      = vm['salt']['minion_config']
          salt.minion_id          = vm['hostname']
          salt.install_master     = vm['salt']['install_master']
          salt.masterless         = vm['salt']['masterless']
          salt.run_highstate      = vm['salt']['run_highstate']
        end
      end

    end
  end
end

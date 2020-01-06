# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'ipaddr'

# default constants
DEFAULT_API_VERSION = 2
DEFAULT_PROVIDER = 'virtualbox'
DEFAULT_CPU = 2
DEFAULT_MEMORY = 1024

# load yaml config
current_dir = File.dirname(File.expand_path(__FILE__))
cfg         = YAML.load_file("#{current_dir}/config.yaml")

# vagrant api version
if cfg['vagrant']
  api_version = cfg['vagrant']['api_version'] || DEFAULT_API_VERSION
else
  api_version = DEFAULT_API_VERSION
end

# extend class IPAddr methods
# https://ruby-doc.org/stdlib-2.5.1/libdoc/ipaddr/rdoc/IPAddr.html
# to_cidr_s: returns string address with cidr mask
# to_mask_s: returns string cidr mask
class IPAddr
  def to_cidr_s
    if @addr
      mask = @mask_addr.to_s(2).count('1')
      "#{to_s}/#{mask}"
    else
      nil
    end
  end

  def to_mask_s
    if @addr
      mask = @mask_addr.to_s(2).count('1')
      "#{mask}"
    else
      nil
    end
  end
end

# initialize vagrant
# https://www.vagrantup.com/docs/
Vagrant.configure(api_version) do |config|
  # begin loop of each machine in config.yaml
  Array(cfg['machines']).each do |vm|

    # begin vm config definition
    config.vm.define vm['hostname'] do |host|
      # handle vm details
      # https://www.vagrantup.com/docs/multi-machine/
      host.vm.box                 = vm['box']
      host.vm.hostname            = vm['hostname']

      # handle vm guest
      # https://www.vagrantup.com/docs/vagrantfile/machine_settings.html#config-vm-guest
      if !vm['guest'].nil?
        host.vm.guest             = :vm['guest']
      end

      # handle vm communicator
      # https://www.vagrantup.com/docs/vagrantfile/machine_settings.html#config-vm-communicator
      if !vm['communicator'].nil?
        host.vm.communicator      = vm['communicator']
      end

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
          v.customize             ['modifyvm', :id, '--cpuexecutioncap', "#{vm['cpuexecutioncap']}"]
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
        case provider
        when 'virtualbox'
          if !net['ip'].nil?
            begin
              # handle static ip interface
              addr = IPAddr.new(String(net['ip']).split('/')[0])
              mask = IPAddr.new(net['ip'])

              host.vm.network     net['type'], virtualbox__intnet: net['net'], ip: addr.to_s, netmask: mask.to_mask_s,
                                  auto_config: net['auto_config'], mac: net['mac']
            rescue IPAddr::InvalidAddressError
              # handle dhcp interface
              host.vm.network     net['type'], virtualbox__intnet: net['net'], type: 'dhcp',
                                  auto_config: net['auto_config'], mac: net['mac']
            end

          # handle generic interface
          else
            host.vm.network       net['type'], virtualbox__intnet: net['net'],
                                  auto_config: net['auto_config'], mac: net['mac']
          end
        # handle non-virtualbox provider networking
        else
          if !net['ip'].nil?
            begin
              # handle static ip interface
              addr = IPAddr.new(String(net['ip']).split('/')[0])
              mask = IPAddr.new(net['ip'])

              host.vm.network     net['type'], ip: addr.to_s, netmask: mask.to_mask_s, auto_config: net['auto_config'],
                                  mac: net['mac']
            rescue IPAddr::InvalidAddressError
              # handle dhcp interface
              host.vm.network     net['type'], type: 'dhcp', auto_config: net['auto_config'],
                                  mac: net['mac']
            end

          # handle generic interface
          else
            host.vm.network       net['type'], auto_config: net['auto_config'], mac: net['mac']
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

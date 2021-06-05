# Check required plugins
REQUIRED_PLUGINS_LIBVIRT = %w(vagrant-libvirt)
exit unless REQUIRED_PLUGINS_LIBVIRT.all? do |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
end

OSVER = "4.4.0"

$script = <<-SCRIPT
  echo "### RUNNING CUMULUS EXTRA CONFIG ###"
  source /etc/lsb-release
  echo "  INFO: Detected Cumulus Linux v$DISTRIB_RELEASE Release"

  echo "### Disabling default remap on Cumulus VX..."
  mv -v /etc/hw_init.d/S10rename_eth_swp.sh /etc/S10rename_eth_swp.sh.backup &> /dev/null

  echo "### Giving Vagrant User Ability to Run NCLU Commands ###"
  adduser vagrant netedit
  adduser vagrant netshow

  echo "### Restart udev for remap interfaces"
  systemctl restart udev.service
  echo "### DONE ###"
SCRIPT

vagrant_ssh_conf = "../Vagrant_ssh.rb"
load File.expand_path(vagrant_ssh_conf) if File.exists?(vagrant_ssh_conf)

Vagrant.configure("2") do |config|

  config.vm.provider :libvirt do |libvirt|
    libvirt.management_network_address = "10.255.1.0/24"
    libvirt.management_network_name = "wbr1"
    libvirt.nic_adapter_count = 130
    libvirt.nic_model_type = "virtio"
  end

# Create VMs

  config.vm.define "mainSw" do |device|

    device.vm.hostname = "mainSw"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:00:01",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8001",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9001",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:00:02",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8002",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9002",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:00:03",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8003",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9003",
          :libvirt__iface_name => 'swp3',
          auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:00:01 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:00:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:00:02 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:00:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:00:03 --> swp3"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:00:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path

  end

  config.vm.define "spine1" do |device|

    device.vm.hostname = "spine1"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:01",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9001",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8001",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:02",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8012",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9012",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:03",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8013",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9013",
          :libvirt__iface_name => 'swp3',
          auto_config: false

    device.vm.network "private_network",
            :mac => "44:38:39:00:01:04",
            :libvirt__tunnel_type => 'udp',
            :libvirt__tunnel_local_ip => '127.0.0.1',
            :libvirt__tunnel_local_port => "8014",
            :libvirt__tunnel_ip => '127.0.0.1',
            :libvirt__tunnel_port => "9014",
            :libvirt__iface_name => 'swp4',
            auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:01 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:02 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:03 --> swp3"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:04 --> swp4"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path

  end

  config.vm.define "spine2" do |device|

    device.vm.hostname = "spine2"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:05",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9002",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8002",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:06",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8022",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9022",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:07",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8023",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9023",
          :libvirt__iface_name => 'swp3',
          auto_config: false

    device.vm.network "private_network",
            :mac => "44:38:39:00:01:08",
            :libvirt__tunnel_type => 'udp',
            :libvirt__tunnel_local_ip => '127.0.0.1',
            :libvirt__tunnel_local_port => "8024",
            :libvirt__tunnel_ip => '127.0.0.1',
            :libvirt__tunnel_port => "9024",
            :libvirt__iface_name => 'swp4',
            auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:05 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:05", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:06 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:06", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:07 --> swp3"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:07", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:08 --> swp4"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:08", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path

  end

  config.vm.define "spine3" do |device|

    device.vm.hostname = "spine3"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:09",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9003",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8003",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:01:10",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8032",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9032",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:09 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:09", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:01:10 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:01:10", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path

  end

  config.vm.define "leaf1" do |device|

    device.vm.hostname = "leaf1"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:01",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8101",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9101",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:02",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9012",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8012",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:03",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9022",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8022",
          :libvirt__iface_name => 'swp3',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:04",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8201",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9201",
          :libvirt__iface_name => 'swp4',
          auto_config: false
    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:01 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:02 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:03 --> swp3"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:04 --> swp4"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path
  end

  config.vm.define "leaf2" do |device|

    device.vm.hostname = "leaf2"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:05",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9101",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8101",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:06",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9013",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8013",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:07",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9023",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8023",
          :libvirt__iface_name => 'swp3',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:08",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8202",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9202",
          :libvirt__iface_name => 'swp4',
          auto_config: false
    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:05 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:05", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:06 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:06", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:07 --> swp3"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:07", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:08 --> swp4"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:08", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path
  end

  config.vm.define "leaf3" do |device|

    device.vm.hostname = "leaf3"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:09",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9014",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8014",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:10",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9024",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8024",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:11",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8203",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9203",
          :libvirt__iface_name => 'swp3',
          auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:09 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:09", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:10 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:10", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:11 --> swp3"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:11", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path
  end

  config.vm.define "leaf4" do |device|

    device.vm.hostname = "leaf4"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:13",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9032",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8032",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:02:14",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "8204",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "9204",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:13 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:13", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:02:14 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:02:14", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path
  end

  config.vm.define "client1" do |device|

    device.vm.hostname = "client1"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:03:01",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9201",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8201",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.network "private_network",
          :mac => "44:38:39:00:03:02",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9202",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8202",
          :libvirt__iface_name => 'swp2',
          auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:03:01 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:03:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:03:01 --> swp2"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:03:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path
  end

  config.vm.define "client2" do |device|

    device.vm.hostname = "client2"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:03:03",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9203",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8203",
          :libvirt__iface_name => 'swp1',
          auto_config: false

          # Install Rules for the interface re-map
    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:03:03 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:03:03", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path
  end

  config.vm.define "client3" do |device|

    device.vm.hostname = "client3"

    device.vm.synced_folder ".", "/vagrant", disabled: true
    device.vm.box = "CumulusCommunity/cumulus-vx"
    device.vm.box_version = OSVER

    device.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 2
    end

    device.vm.network "private_network",
          :mac => "44:38:39:00:03:04",
          :libvirt__tunnel_type => 'udp',
          :libvirt__tunnel_local_ip => '127.0.0.1',
          :libvirt__tunnel_local_port => "9204",
          :libvirt__tunnel_ip => '127.0.0.1',
          :libvirt__tunnel_port => "8204",
          :libvirt__iface_name => 'swp1',
          auto_config: false

    device.vm.provision :shell, :inline => <<-delete_udev_directory
      rm -rfv /etc/udev/rules.d/70-persistent-net.rules &> /dev/null
    delete_udev_directory

    device.vm.provision :shell, :inline => <<-udev_rule
      echo "  INFO: Adding UDEV Rule: 44:38:39:00:03:04 --> swp1"
      echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:38:39:00:03:04", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
    udev_rule

    device.vm.provision :shell, :inline => $script
    provision_script_path = "../#{TASK}/scripts/#{device.vm.hostname}.sh"
    device.vm.provision :shell, path: provision_script_path
  end
end
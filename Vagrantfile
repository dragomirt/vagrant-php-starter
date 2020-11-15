Vagrant.configure("2") do |config|

    config.vm.provider "virtualbox" do |v|
      v.memory = 1536
      v.cpus = 2
    end

    config.vm.box = "debian/buster64"

    config.vm.network "private_network", ip: "192.168.33.10"

    config.vm.synced_folder ".", "/var/www/html", type: "nfs"

    config.vm.provision :shell, path: "provision.sh"
end

# Docker nginx with php5
Use in combination with digitalpatrioten/nginx-configurations

Sample Vagrantfile

	# -*- mode: ruby -*-
	# vi: set ft=ruby :
	
	# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
	VAGRANTFILE_API_VERSION = "2"
	
	Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	  config.vm.box = "phusion/ubuntu-14.04-amd64"
	  config.vm.network "private_network", ip: "192.168.33.10"
	  config.vm.synced_folder "./", "/vagrant", id: "vagrant-root",
	      owner: "www-data",
	      group: "www-data",
	      mount_options: ["dmode=755,fmode=644"]
	  config.vm.provider :virtualbox do |vb|
	    vb.customize ["modifyvm", :id, "--natnet1", "172.16/12"]
	    vb.customize ["modifyvm", :id, "--memory", "2048"]
	  end
	  config.vm.provision "docker" do |d|
	    d.pull_images "mysql"
	    d.pull_images "digitalpatrioten/nginx-configurations"
	    d.pull_images "digitalpatrioten/nginx-php5"
	    d.pull_images "obi12341/solr-typo3"
	    d.run "mysql",
	      image: "mysql",
	      args: "--name mysql -e MYSQL_ROOT_PASSWORD=password -p 3306:3306"
	    d.run "obi12341/solr-typo3",
	      image: "obi12341/solr-typo3",
	      args: "--name solr -p 8080:8080"
	    d.run "digitalpatrioten/nginx-configurations",
	      image: "digitalpatrioten/nginx-configurations",
	      args: "--name nginx-configurations"
	    d.run "digitalpatrioten/nginx-php5",
	      image: "digitalpatrioten/nginx-php5",
	      args: "-v '/vagrant:/var/www' --volumes-from nginx-configurations -e 'SITES_CONFIGS=default-typo3,default-ssl-typo3' -p 80:80 -p 443:443 --link mysql:mysql --link solr:solr"
	    end
	end

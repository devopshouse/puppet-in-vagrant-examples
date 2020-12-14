## Puppet demo
Demo repository to demonstrate how to use puppet 7.

## Requirements
* Virtualbox installed: https://www.virtualbox.org/wiki/Downloads
* Hashcorp Vagrant installed: https://www.vagrantup.com/downloads

## Instructions

To simplify to installation process 3 Vagrant Boxes will be used, as defined in the `nodes.json` file, change the ip address or memory settings.

```json
{
  "nodes": {
    "master": {
      ":ip": "192.168.32.5",
      ":memory": 2048,
      ":bootstrap": "scripts/bootstrap-master.sh"
    },
    "node01": {
      ":ip": "192.168.32.10",
      ":memory": 512,
      ":bootstrap": "scripts/bootstrap-node.sh"
    },
    "node02": {
      ":ip": "192.168.32.20",
      ":memory": 512,
      ":bootstrap": "scripts/lbootstrap-node.sh"
    }
  }
}
```

### Provision instructions

1. Download and install **Vagrant** from https://www.vagrantup.com/downloads

2. Clone the git repo
```
git clone https://github.com/devopshouse/puppet-in-vagrant-examples.git
```

3.  Enter repo dir
```
cd puppet-in-vagrant-examples/provision
```

4. Provision the required infrastructure with Vagrant
```
vagrant up
```

### Puppet Server Configuration
The Puppet Server initial installation and configuration process was done by the bootstrap scripts **bootstrap-master.sh**. The Puppet agent nodes were configured using the **bootstrap-node.sh** bootstrap script. During the agent initialization new certificates request were generated.

To verify agent certificates executed the following commands:

1. SSH into Puppet Server
```
vagrant ssh master
```

2. Become root into master server
```
sudo -i
```

3. List the agent certificates
```
puppetserver ca list
```

Output:

```
Requested Certificates:
    node01.station       (SHA256)  C1:A7:53:D0:45:7C:F1:A5:78:9F:EE:1F:08:D1:31:39:53:67:69:CE:4C:A4:EF:E4:E2:9C:5C:AA:78:5B:FE:61
    node02.station       (SHA256)  F6:82:45:43:B3:39:A8:7B:ED:22:FD:C4:D9:11:2C:E5:C3:55:B9:CB:64:AF:C9:69:27:F0:02:21:7A:CC:C9:A1
```

The command output shows the the agent certificate request.

4. Sign agent certificates
Sign specific agent certificate.

```
puppetserver ca sign --certname=node01.station
puppetserver ca sign --certname=node02.station
```

Sign all agent certificates.

```
puppetserver ca sign --all
```

### Test Puppet Agent Communication
1. SSH into Puppet Server
```
vagrant ssh node01
```

2. Become root into node server
```
sudo -i
```

3. Test Puppet configuration
```
puppet agent --test
```

### Deploy a Web Server Using Puppet
1. SSH into Puppet Server
```
vagrant ssh master
```

2. Become root into master server
```
sudo -i
```

3. Go to puppet production environment
```
cd /etc/puppetlabs/code/environments/production
```

4 . Create the web server module folder structure
```
mkdir -p modules/webserver/{files,manifests}
```

5. Create the module definition in `/etc/puppetlabs/code/environments/production/modules/webserver/manifests/init.pp` with the following content:
```
class webserver {
  package { 
    'apache2': 
    ensure => installed 
  }

  file { "/var/www/html/index.html":
    ensure => file,
    mode   => '755',
    owner  => root,
    group  => root,
    source => "puppet:///modules/webserver/index.html",
    require => Package['apache2']
  }
  
  service {
    'apache2':
    ensure => true,
    enable => true,
    require => Package['apache2']
  }
}
```

6. Create the web server document root definition in `/etc/puppetlabs/code/environments/production/modules/webserver/files/index.html` with the following content:
```
<html>
  <head>
    <title>Congratulations</title>
  <head>
  <body>
    <h1>Congratulations</h1>
    <p>Apache index.html installed by Puppet.</p>
  </body>
</html>
```

7. Create the new manifest to be deploy in all nodes in `/etc/puppetlabs/code/environments/production/manifests/site.pp` with the following content:
```
node default {
   include webserver
}
```

8. Wait the amount of time configured in `runinterval` in the puppet agent node configuration file `/etc/puppetlabs/puppet/puppet.conf` or login in the node and manually trigger the update:
```
vagrant ssh node01
```

Become root into node
```
sudo -i
```

Force the configuration update
```
puppet agent --test
```

Check for the web server installation:
```
curl 127.0.0.1
<html>
  <head>
    <title>Congratulations</title>
  <head>
  <body>
    <h1>Congratulations</h1>
    <p>Apache index.html installed by Puppet.</p>
  </body>
</html>
```

# Run on VM to bootstrap Puppet Master server
 
if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Exiting..."
else
    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    master.station  master" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.station  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   node01.station  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.20   node02.station  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Install Puppet Agent
    wget https://apt.puppetlabs.com/puppet7-release-bionic.deb && \
    sudo dpkg -i puppet7-release-bionic.deb && \
    sudo apt-get update -yq && sudo apt-get upgrade -yq && \
    sudo apt-get install -yq puppet-agent

    # Configure puppet master DNS name in /etc/puppetlabs/puppet/puppet.conf
    echo -e "" && echo -e "[agent]\nserver=master.station" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null
    echo -e "" && echo -e "[main]\nruninterval=2m" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null
    
    sudo systemctl restart puppet
fi
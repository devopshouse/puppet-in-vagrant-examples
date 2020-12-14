# Run on VM to bootstrap Puppet Master server
 
if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    master.station  master" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.5    puppet.station  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.10   node01.station  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.32.20   node02.station  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Install Puppet Master
    wget https://apt.puppetlabs.com/puppet7-release-bionic.deb && \
    sudo dpkg -i puppet7-release-bionic.deb && \
    sudo apt-get update -yq && sudo apt-get upgrade -yq && \
    sudo apt-get install -yq puppetserver

    # Setting JVM params /etc/default/puppetserver
    sudo sed -i 's/JAVA_ARGS=.*/JAVA_ARGS="-Xms1g -Xmx1g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"/' /etc/default/puppetserver

    # Add optional alternate DNS names to /etc/puppetlabs/puppet/puppet.conf
    echo "" && echo -e "\n[main]\ndns_alt_names=puppet,puppet.station,master,master.station" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null

    # Restarting pupper server
    sudo systemctl restart puppetserver
fi

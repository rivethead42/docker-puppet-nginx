FROM ubuntu:16.04

ENV PUPPET_AGENT_VERSION="1.8.2" R10K_VERSION="2.2.2" CODENAME="xenial" 

RUN apt-get update && \
    apt-get install --no-install-recommends -y lsb-release wget ca-certificates && \
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-"$CODENAME".deb && \
    dpkg -i puppetlabs-release-pc1-"$CODENAME".deb && \
    rm puppetlabs-release-pc1-"$CODENAME".deb && \
    apt-get update && \
    apt-get install --no-install-recommends -y puppet-agent="$PUPPET_AGENT_VERSION"-1"$CODENAME" && \
    apt-get remove --purge -y wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    mkdir -p /etc/puppetlabs/facter/facts.d/ && \
    rm -rf /var/lib/apt/lists/* 

RUN apt-get update && \
    apt-get install --no-install-recommends -y git-core && \
    /opt/puppetlabs/puppet/bin/gem install r10k:"$R10K_VERSION" --no-ri --no-rdoc && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

COPY Puppetfile /Puppetfile
RUN /opt/puppetlabs/puppet/bin/r10k puppetfile install --moduledir /etc/puppetlabs/code/modules

COPY manifests /manifests

  
    
RUN apt-get update && \
    FACTER_hostname=nginx /opt/puppetlabs/bin/puppet apply manifests/init.pp --detailed-exitcodes --verbose --show_diff --summarize  --app_management ; \
    rc=$?; if [ $rc -ne 0 ] && [ $rc -ne 2 ]; then exit 1; fi && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 
    
  

LABEL com.puppet.inventory="/inventory.json"
RUN /opt/puppetlabs/bin/puppet module install puppetlabs-inventory && \
    /opt/puppetlabs/bin/puppet inventory all > /inventory.json

EXPOSE 80

CMD ["nginx"]

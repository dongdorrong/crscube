yum -y install dnsmasq vim procps bind-utils tcpdump
groupadd -r dnsmasq && useradd -r -g dnsmasq dnsmasq
cp -af /etc/dnsmasq.conf /etc/dnsmasq.conf.origin
vim /etc/dnsmasq.conf
#######################################
# Server Configuration
listen-address=127.0.0.1
port=53
bind-interfaces
user=dnsmasq
group=dnsmasq
pid-file=/var/run/dnsmasq.pid

# Name resolution options
resolv-file=/etc/resolv.dnsmasq
cache-size=500
neg-ttl=60
domain-needed
bogus-priv
#######################################
touch /etc/resolv.dnsmasq
bash -c "echo 'nameserver 169.254.169.253' > /etc/resolv.dnsmasq"                                                                 

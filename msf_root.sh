cd /var
touch swap.img
chmod 600 swap.img
dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
swapon /var/swap.img

mkdir /pentest
cd /pentest

apt update
apt -y upgrade

apt -y install build-essential zlib1g zlib1g-dev libxml2 libxml2-dev libxslt-dev locate libreadline6-dev libcurl4-openssl-dev git-core libssl-dev libyaml-dev openssl autoconf libtool ncurses-dev bison curl wget postgresql postgresql-contrib libpq-dev libapr1 libaprutil1 libsvn1 libpcap-dev libsqlite3-dev libgmp-dev

git clone https://github.com/rapid7/metasploit-framework.git

curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -L https://get.rvm.io | bash -s stable

source /usr/local/rvm/scripts/rvm
source /etc/profile.d/rvm.sh
echo "source /usr/local/rvm/scripts/rvm" >> /root/.profile
echo "source /etc/profile.d/rvm.sh" >> /root/.profile

cd metasploit-framework
rvm install ruby-`cat .ruby-version`
cd ..
cd metasploit-framework
gem install bundler
bundle install

PASSZ=`strings /dev/urandom |grep -o [a-zA-Z0-9] |head -n 16|tr -d '\n'`

sudo -u postgres createuser msf -dRS
sudo -u postgres psql -c "ALTER USER msf with ENCRYPTED PASSWORD '${PASSZ}';"
sudo -u postgres createdb --owner msf msf_dev_db

cp /pentest/metasploit-framework/config/database.yml.example /root/.msf4/database.yml
sed -i "s/ database: metasploit_framework_development/ database: msf_dev_db/" /root/.msf4/database.yml
sed -i "s/ username: metasploit_framework_development/ username: msf/" /root/.msf4/database.yml
sed -i "s/ password: __________________________________/ password: ${PASSZ}/" /root/.msf4/database.yml



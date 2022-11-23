cd /app/src/plugins/perl-base/Dockerfiles

apt-get update

apt-get install -y apt-utils software-properties-common build-essential \
                   vim screen htop exuberant-ctags ntp net-tools ntpdate \
                   libxml2-dev libxslt1-dev rsync libnet-ssleay-perl \
                   net-tools unzip less psmisc git openssh-client \
                   libsasl2-dev libmagic-dev

## Basic Perl Module to start with
HOME=/tmp/setup cpanm --notest --installdeps .
rm -fr /tmp/setup

## Applications to be run
cp service.pl /usr/local/bin/process

chmod 0755 -R /usr/local/bin/process

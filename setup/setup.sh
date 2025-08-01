#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy
apt-get install -qy git git-lfs mc binutils

# add custom trusted CA certificates
if ls /setup/trusted-ca-certificates/*.crt &> /dev/null ; then
    cp /setup/trusted-ca-certificates/*.crt /usr/local/share/ca-certificates/
    /usr/sbin/update-ca-certificates
fi

source /etc/profile

# install and configure JDK
mkdir -p /java/tmp
tar -C /java/tmp -xzf /java/jdk.tar.gz
mv /java/tmp/* /java/jdk
rm /java/jdk.tar.gz
rmdir /java/tmp

# install Groovy
mkdir -p /java/tmp
unzip /java/groovy.zip -d /java/tmp
mv /java/tmp/* /java/groovy
rm /java/groovy.zip
rmdir /java/tmp

# install Gradle
mkdir -p /java/tmp
unzip /java/gradle.zip -d /java/tmp
mv /java/tmp/* /java/gradle
rm /java/gradle.zip
rmdir /java/tmp

# install Maven
mkdir -p /java/tmp
tar -C /java/tmp -xzf /java/maven.tar.gz
mv /java/tmp/* /java/maven
rm /java/maven.tar.gz
rmdir /java/tmp

# install Ant
mkdir -p /java/tmp
tar -C /java/tmp -xzf /java/ant.tar.gz
mv /java/tmp/* /java/ant
rm /java/ant.tar.gz
rmdir /java/tmp

java -Xshare:dump

# cleanup
source /setup/cleanup-image.sh

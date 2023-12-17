#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy
apt-get install -qy git git-lfs mc

source /etc/profile

# install and configure JDK
mkdir -p /java/tmp
tar -C /java/tmp -xzf /java/jdk17.tar.gz
mv /java/tmp/* /java/jdk17
rm /java/jdk17.tar.gz
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


# cleanup
source /setup/cleanup-image.sh

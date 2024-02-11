#!/bin/bash

set -ex

cd "${0%/*}"

JDK_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz"
JDK_ARCHIVE="$(basename $JDK_URL)"

cd tmp
[ -e ${JDK_ARCHIVE} ] || curl -L $JDK_URL -o ${JDK_ARCHIVE} || exit 1
cd ..


GRADLE_URL="https://services.gradle.org/distributions/gradle-8.6-bin.zip"
GRADLE_ARCHIVE="$(basename $GRADLE_URL)"

cd tmp
[ -e ${GRADLE_ARCHIVE} ] || curl -L $GRADLE_URL -o ${GRADLE_ARCHIVE} || exit 1
cd ..


MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz"
MAVEN_ARCHIVE="$(basename $MAVEN_URL)"

cd tmp
[ -e ${MAVEN_ARCHIVE} ] || curl -L $MAVEN_URL -o ${MAVEN_ARCHIVE} || exit 1
cd ..


ANT_URL="https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.14-bin.tar.gz"
ANT_ARCHIVE="$(basename $ANT_URL)"

cd tmp
[ -e ${ANT_ARCHIVE} ] || curl -L $ANT_URL -o ${ANT_ARCHIVE} || exit 1
cd ..


CONT=$(buildah from veita/debian-base:bookworm)

buildah copy $CONT etc/ /etc
buildah copy $CONT setup/ /setup
buildah copy $CONT tmp/${JDK_ARCHIVE} /java/jdk.tar.gz
buildah copy $CONT tmp/${GRADLE_ARCHIVE} /java/gradle.zip
buildah copy $CONT tmp/${MAVEN_ARCHIVE} /java/maven.tar.gz
buildah copy $CONT tmp/${ANT_ARCHIVE} /java/ant.tar.gz
buildah run $CONT /bin/bash /setup/setup.sh
buildah run $CONT rm -rf /setup

buildah config --workingdir '/qsk' $CONT
buildah config --cmd '/bin/bash --login' $CONT

buildah config --author "Alexander Veit" $CONT
buildah config --label commit=$(git describe --always --tags --dirty=-dirty) $CONT

buildah commit --rm $CONT localhost/java-toolchain:17

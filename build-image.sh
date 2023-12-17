#!/bin/bash

set -ex

cd "${0%/*}"

JDK_ARCHIVE="jdk17.tar.gz"
JDK_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jdk_x64_linux_hotspot_17.0.9_9.tar.gz"

cd tmp
[ -e ${JDK_ARCHIVE} ] || curl -L $JDK_URL -o ${JDK_ARCHIVE} || exit 1
cd ..


GRADLE_ARCHIVE="gradle.zip"
GRADLE_URL="https://services.gradle.org/distributions/gradle-8.5-bin.zip"

cd tmp
[ -e ${GRADLE_ARCHIVE} ] || curl -L $GRADLE_URL -o ${GRADLE_ARCHIVE} || exit 1
cd ..


MAVEN_ARCHIVE="maven.tar.gz"
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz"

cd tmp
[ -e ${MAVEN_ARCHIVE} ] || curl -L $MAVEN_URL -o ${MAVEN_ARCHIVE} || exit 1
cd ..


ANT_ARCHIVE="ant.tar.gz"
ANT_URL="https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.14-bin.tar.gz"

cd tmp
[ -e ${ANT_ARCHIVE} ] || curl -L $ANT_URL -o ${ANT_ARCHIVE} || exit 1
cd ..


CONT=$(buildah from veita/debian-base:bookworm)

buildah copy $CONT etc/ /etc
buildah copy $CONT setup/ /setup
buildah copy $CONT tmp/${JDK_ARCHIVE} /java/${JDK_ARCHIVE}
buildah copy $CONT tmp/${GRADLE_ARCHIVE} /java/${GRADLE_ARCHIVE}
buildah copy $CONT tmp/${MAVEN_ARCHIVE} /java/${MAVEN_ARCHIVE}
buildah copy $CONT tmp/${ANT_ARCHIVE} /java/${ANT_ARCHIVE}
buildah run $CONT /bin/bash /setup/setup.sh
buildah run $CONT rm -rf /setup

buildah config --workingdir '/qsk' $CONT
buildah config --cmd '/bin/bash --login' $CONT

buildah config --author "Alexander Veit" $CONT
buildah config --label commit=$(git describe --always --tags --dirty=-dirty) $CONT

buildah commit --rm $CONT localhost/java-toolchain:latest
buildah tag localhost/java-toolchain:latest localhost/java-toolchain:17

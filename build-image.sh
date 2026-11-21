#!/bin/bash

set -exuo pipefail

cd "${0%/*}"

# JDK
JDK_VERSION="17.0.21.1+2"
IMAGE_TYPE="jdk"
OS="linux"
ARCHITECTURE="x64"
RELEASE_NAME="jdk-${JDK_VERSION}"
JDK_URL="https://api.adoptium.net/v3/binary/version/${RELEASE_NAME}/${OS}/${ARCHITECTURE}/${IMAGE_TYPE}/hotspot/normal/eclipse"
JDK_SIG_URL="https://api.adoptium.net/v3/signature/version/${RELEASE_NAME}/${OS}/${ARCHITECTURE}/${IMAGE_TYPE}/hotspot/normal/eclipse"
JDK_ARCHIVE="${RELEASE_NAME}-${IMAGE_TYPE}-${OS}-${ARCHITECTURE}.tar.gz"

cd tmp
[ -e ${JDK_ARCHIVE} ] || curl -L $JDK_URL -o ${JDK_ARCHIVE} || exit 1
cd ..

# Gradle
GRADLE_VERSION="8.14.8"
GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
GRADLE_ARCHIVE="$(basename $GRADLE_URL)"

cd tmp
[ -e ${GRADLE_ARCHIVE} ] || curl -L $GRADLE_URL -o ${GRADLE_ARCHIVE} || exit 1
cd ..

# Maven
MVN_VERSION="3.10.1"
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz"
MAVEN_ARCHIVE="$(basename $MAVEN_URL)"

cd tmp
[ -e ${MAVEN_ARCHIVE} ] || curl -L $MAVEN_URL -o ${MAVEN_ARCHIVE} || exit 1
cd ..

#Ant
ANT_VERSION="1.10.18"
ANT_URL="https://dlcdn.apache.org//ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz"
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

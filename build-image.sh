#!/bin/bash

set -ex

cd "${0%/*}"

# JDK
VERSION="21.0.7+6"
IMAGE_TYPE="jdk"
OS="linux"
ARCHITECTURE="x64"
RELEASE_NAME="jdk-${VERSION}"

JDK_URL="https://api.adoptium.net/v3/binary/version/${RELEASE_NAME}/${OS}/${ARCHITECTURE}/${IMAGE_TYPE}/hotspot/normal/eclipse"
JDK_SIG_URL="https://api.adoptium.net/v3/signature/version/${RELEASE_NAME}/${OS}/${ARCHITECTURE}/${IMAGE_TYPE}/hotspot/normal/eclipse"
JDK_ARCHIVE="${RELEASE_NAME}-${IMAGE_TYPE}-${OS}-${ARCHITECTURE}.tar.gz"

cd tmp
[ -e ${JDK_ARCHIVE} ] || curl -L --fail $JDK_URL -o ${JDK_ARCHIVE} || exit 1
cd ..

# Groovy
GROOVY_URL="https://groovy.jfrog.io/artifactory/dist-release-local/groovy-zips/apache-groovy-binary-4.0.27.zip"
GROOVY_ARCHIVE="$(basename $GROOVY_URL)"

cd tmp
[ -e ${GROOVY_ARCHIVE} ] || curl -L --fail $GROOVY_URL -o ${GROOVY_ARCHIVE} || exit 1
cd ..

# Gradle
GRADLE_URL="https://services.gradle.org/distributions/gradle-8.14.2-bin.zip"
GRADLE_ARCHIVE="$(basename $GRADLE_URL)"

cd tmp
[ -e ${GRADLE_ARCHIVE} ] || curl -L --fail $GRADLE_URL -o ${GRADLE_ARCHIVE} || exit 1
cd ..

# Maven
MVN_VERSION="3.9.10"
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz"
MAVEN_ARCHIVE="$(basename $MAVEN_URL)"

cd tmp
[ -e ${MAVEN_ARCHIVE} ] || curl -L --fail $MAVEN_URL -o ${MAVEN_ARCHIVE} || exit 1
cd ..

# Ant
ANT_URL="https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.15-bin.tar.gz"
ANT_ARCHIVE="$(basename $ANT_URL)"

cd tmp
[ -e ${ANT_ARCHIVE} ] || curl -L --fail $ANT_URL -o ${ANT_ARCHIVE} || exit 1
cd ..


CONT=$(buildah from veita/debian-base:bookworm)

buildah copy $CONT etc/ /etc
buildah copy $CONT setup/ /setup
buildah copy $CONT tmp/${JDK_ARCHIVE} /java/jdk.tar.gz
buildah copy $CONT tmp/${GROOVY_ARCHIVE} /java/groovy.zip
buildah copy $CONT tmp/${GRADLE_ARCHIVE} /java/gradle.zip
buildah copy $CONT tmp/${MAVEN_ARCHIVE} /java/maven.tar.gz
buildah copy $CONT tmp/${ANT_ARCHIVE} /java/ant.tar.gz
buildah run $CONT /bin/bash /setup/setup.sh
buildah run $CONT rm -rf /setup

buildah config --workingdir '/qsk' $CONT

buildah config --env JAVA_HOME=/java/jdk $CONT
buildah config --env GROOVY_HOME=/java/groovy $CONT
buildah config --env GRADLE_HOME=/java/gradle $CONT
buildah config --env ANT_HOME=/java/ant $CONT
buildah config --env MVN_HOME=/java/maven $CONT
buildah config --env PATH=/java/jdk/bin:/java/groovy/bin:/java/gradle/bin:/java/maven/bin:/java/ant/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $CONT

buildah config --author "Alexander Veit" $CONT
buildah config --label commit=$(git describe --always --tags --dirty=-dirty) $CONT

buildah commit --rm $CONT localhost/java-toolchain:latest
buildah tag localhost/java-toolchain:latest localhost/java-toolchain:21

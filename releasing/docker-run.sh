#!/usr/bin/env bash
# Copyright 2020-2021 The Verible Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

cd $(dirname "$0")

# Get target OS and version

if [ -z "${1}" ]; then
  echo "Make sure that \$1 ($1) is set."
  exit 1
fi

export TARGET=`echo "$1" | sed 's#:#-#g'`

TARGET_VERSION=`echo $TARGET | cut -d- -f2`
TARGET_OS=`echo $TARGET | cut -d- -f1`

export TAG=${TAG:-$(git describe --match=v*)}

if [ -z "${BAZEL_VERSION}" ]; then
  echo "Make sure that \$BAZEL_VERSION ($BAZEL_VERSION) is set."
  echo " (try 'source ../.github/settings.sh')"
  exit 1
fi
if [ -z "${BAZEL_OPTS}" ]; then
  echo "Make sure that \$BAZEL_OPTS ($BAZEL_OPTS) is set."
  echo " (try 'source ../.github/settings.sh')"
  exit 1
fi
if [ -z "${BAZEL_CXXOPTS}" ]; then
  echo "Make sure that \$BAZEL_CXXOPTS ($BAZEL_CXXOPTS) is set."
  echo " (try 'source ../.github/settings.sh')"
  exit 1
fi

# Generate the Dockerfile
OUT_DIR=${TARGET_OS}-${TARGET_VERSION}
FB=${STAGE}.dockerfile
F1=${TARGET_OS}/${TARGET_VERSION}/${FB}
F2=${TARGET_OS}/common/${FB}
F3=${FB}

STAGES="compiler bazel gflags2man"

mkdir $OUT_DIR
sed "s#${TARGET_OS}:VERSION#${TARGET_OS}:${TARGET_VERSION}#g" ${TARGET_OS}.dockerfile > ${OUT_DIR}/Dockerfile
for STAGE in compiler bazel; do
	if [ -e $F1 ]; then
		echo "Using version override $F1"
		cat $F1 >> ${OUT_DIR}/Dockerfile
	elif [ -e $F2 ]; then
		echo "Using OS override $F2"
		cat $F2 >> ${OUT_DIR}/Dockerfile
	elif [ -e $F3 ]; then
		echo "Using top file $F3"
		cat $F3 >> ${OUT_DIR}/Dockerfile
	else
		echo "Unable to find ${STAGE} for ${TARGET_OS} version ${TARGET_VERSION}"
		echo
		echo "Tried:"
		echo " $F1"
		echo " $F2"
		echo " $F3"
		exit 1
	fi
done

# ==================================================================

REPO_SLUG=${GITHUB_REPOSITORY_SLUG:-google/verible}
GIT_DATE=${GIT_DATE:-$(git show -s --format=%ci)}
GIT_VERSION=${GIT_VERSION:-$(git describe --match=v*)}
GIT_HASH=${GIT_HASH:-$(git rev-parse HEAD)}

# Build Verible

cat >> ${TARGET_OS}-${TARGET_VERSION}/Dockerfile <<EOF
ENV BAZEL_OPTS "${BAZEL_OPTS}"
ENV BAZEL_CXXOPTS "${BAZEL_CXXOPTS}"

ENV REPO_SLUG $REPO_SLUG
ENV GIT_VERSION $GIT_VERSION
ENV GIT_DATE $GIT_DATE
ENV GIT_HASH $GIT_HASH

RUN which bazel
RUN bazel --version

ADD verible-$GIT_VERSION.tar.gz /src/verible
WORKDIR /src/verible/verible-$GIT_VERSION

RUN bazel build --workspace_status_command=bazel/build-version.sh $BAZEL_OPTS //...
EOF

(cd .. ; git archive --prefix verible-$GIT_VERSION/ --output releasing/$TARGET/verible-$GIT_VERSION.tar.gz HEAD)

IMAGE="verible:$TARGET-$TAG"

echo "::group::Docker file for $IMAGE"
cat $TARGET/Dockerfile
echo '::endgroup::'

echo "::group::Docker build $IMAGE"
docker build \
  --tag $IMAGE \
  --build-arg BAZEL_VERSION="$BAZEL_VERSION" \
  --build-arg TARGET_VERSION="$TARGET_VERSION" \
  $TARGET
echo '::endgroup::'

echo "::group::Build in container"
mkdir -p out
docker run --rm \
  -e BAZEL_OPTS="${BAZEL_OPTS}" \
  -e BAZEL_CXXOPTS="${BAZEL_CXXOPTS}" \
  -e REPO_SLUG="${GITHUB_REPOSITORY_SLUG:-google/verible}" \
  -e GIT_VERSION="${GIT_VERSION:-$(git describe --match=v*)}" \
  -e GIT_DATE="${GIT_DATE:-$(git show -s --format=%ci)}" \
  -e GIT_HASH="${GIT_HASH:-$(git rev-parse HEAD)}" \
  -v $(pwd)/out:/out \
  $IMAGE \
  ./releasing/build.sh
echo '::endgroup::'

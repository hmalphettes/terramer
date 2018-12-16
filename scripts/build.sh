#!/usr/bin/env bash
#
# This script builds the application from source for multiple platforms.
# Source - linted with shellcheck - https://github.com/hashicorp/terraform/blob/master/scripts/build.sh

# Get the parent directory of where this script is.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$(cd -P "$( dirname "$SOURCE" )/.." && pwd)"

# Change into that directory
cd "$DIR" || exit 1

# Get the git commit
GIT_COMMIT=$(git rev-parse HEAD)
GIT_DIRTY=$(test -n "$(git status --porcelain)" && echo "+CHANGES" || true)

# Determine the arch/os combos we're building for
XC_ARCH=${XC_ARCH:-"386 amd64 arm"}
XC_OS=${XC_OS:-linux darwin windows freebsd openbsd solaris}
XC_EXCLUDE_OSARCH="!darwin/arm !darwin/386"

# Delete the old dir
echo "==> Removing old directory..."
rm -f bin/*
rm -rf pkg/*
mkdir -p bin/

# If its dev mode, only build for ourself
if [ "${TF_DEV}x" != "x" ]; then
    XC_OS=$(go env GOOS)
    XC_ARCH=$(go env GOARCH)
fi

if ! gox -v > /dev/null; then
    echo "==> Installing gox..."
    go get -u github.com/mitchellh/gox
fi

# instruct gox to build statically linked binaries
export CGO_ENABLED=0

# Allow LD_FLAGS to be appended during development compilations
LD_FLAGS="-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY} $LD_FLAGS"

# In release mode we don't want debug information in the binary
if [[ -n "${TF_RELEASE}" ]]; then
    LD_FLAGS="-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY} -X github.com/hashicorp/terraform/version.Prerelease= -s -w"
fi

# Ensure all remote modules are downloaded and cached before build so that
# the concurrent builds launched by gox won't race to redundantly download them.
go mod download

# Build!
echo "==> Building..."
gox \
    -os="${XC_OS}" \
    -arch="${XC_ARCH}" \
    -osarch="${XC_EXCLUDE_OSARCH}" \
    -ldflags "${LD_FLAGS}" \
    -output "pkg/{{.OS}}_{{.Arch}}/${PWD##*/}" \
    .

# Move all the compiled things to the $GOPATH/bin
GOPATH=${GOPATH:-$(go env GOPATH)}
case $(uname) in
    CYGWIN*)
        GOPATH="$(cygpath "$GOPATH")"
        ;;
esac

declare -a MAIN_GOPATH
while IFS=: read -r line; do MAIN_GOPATH+=("$line"); done < <(echo "$GOPATH")

# Create GOPATH/bin if it's doesn't exists
if [ ! -d "${MAIN_GOPATH[0]}/bin" ]; then
    echo "==> Creating GOPATH/bin directory - ${MAIN_GOPATH[0]}/bin - ..."
    mkdir -p "${MAIN_GOPATH[0]}/bin"
fi

# Copy our OS/Arch to the bin/ directory
DEV_PLATFORM="./pkg/$(go env GOOS)_$(go env GOARCH)"
if [ -d "${DEV_PLATFORM}" ]; then
    while IFS= read -r -d '' F; do
        cp "$F" bin/
        cp "$F" "${MAIN_GOPATH[0]}/bin/"
    done <   <(find "${DEV_PLATFORM}" -mindepth 1 -maxdepth 1 -type f -print0)
fi

if [ "${TF_DEV}x" = "x" ]; then
    # Zip and copy to the dist dir
    echo "==> Packaging..."
    while IFS= read -r -d '' F; do
        OSARCH=$(basename ${PLATFORM})
        echo "--> ${OSARCH}"
        pushd "$PLATFORM" >/dev/null 2>&1 || exit 1
        zip "../${OSARCH}.zip" ./*
        popd >/dev/null 2>&1 || exit 1
    done <   <(find ./pkg -mindepth 1 -maxdepth 1 -type d -print0)
fi

# Done!
echo
echo "==> Results:"
ls -lh bin/

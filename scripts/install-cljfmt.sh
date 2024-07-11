#!/usr/bin/env bash

set -euo pipefail

DEFAULT_INSTALL_DIR="/usr/local/bin"
INSTALL_DIR="$DEFAULT_INSTALL_DIR"
DEFAULT_DOWNLOAD_DIR="/tmp"
DOWNLOAD_DIR="$DEFAULT_DOWNLOAD_DIR"
VERSION=""

print_help() {
    echo -e
    echo "Usage:"
    echo "install [--dir <dir>] [--download-dir <download-dir>] [--version <version>]"
    echo -e
    echo "Defaults:"
    echo " * Installation directory: ${DEFAULT_INSTALL_DIR}"
    echo " * Download directory: ${DEFAULT_DOWNLOAD_DIR}"
    echo " * Version: <Latest release on Github>"
    exit 1
}

while [[ $# -gt 0 ]]; do
    key="$1"
    if [[ -z "${2:-}" ]]; then
        print_help
    fi

    case $key in
    --dir)
        INSTALL_DIR="$2"
        shift 2
        ;;
    --download-dir)
        DOWNLOAD_DIR="$2"
        shift 2
        ;;
    --version | --release-version)
        VERSION="$2"
        shift 2
        ;;
    *) # unknown option
        print_help
        shift
        ;;
    esac
done

if [[ "$VERSION" == "" ]]; then
    VERSION="$(curl -s https://api.github.com/repos/weavejester/cljfmt/releases/latest | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\([^"]*\)"/\1/')"
fi

case "$(uname -s)" in
Linux*)
    PLATFORM=linux
    ;;
Darwin*)
    PLATFORM=darwin
    ;;
esac

STATIC_SUFFIX=""

case "$(uname -m)" in
aarch64)
    ARCH=aarch64
    ;;
arm64)
    ARCH="aarch64"
    ;;
*)
    ARCH=amd64
    # always use static image on linux
    if [[ "${PLATFORM}" == "linux" ]]; then
        STATIC_SUFFIX="-static"
    fi
    ;;
esac

BASE_URL="https://github.com/weavejester/cljfmt/releases/download"

FILENAME="cljfmt-${VERSION}-${PLATFORM}-${ARCH}${STATIC_SUFFIX}.tar.gz"

DOWNLOAD_URL="${BASE_URL}/${VERSION}/${FILENAME}"

mkdir -p "${DOWNLOAD_DIR}"
pushd "${DOWNLOAD_DIR}" >/dev/null

echo -e "Downloading ${DOWNLOAD_URL} to ${DOWNLOAD_DIR}"
curl -o "${FILENAME}" -sL "${DOWNLOAD_URL}"

echo -e "Unpacking ${FILENAME} to ${INSTALL_DIR}"
tar -xzf "${FILENAME}" -C "${INSTALL_DIR}"
rm "$FILENAME"
echo "Done!"

popd >/dev/null

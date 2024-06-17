#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
# We need to compile this for linux ourselves (:
sudo apt-get install gcc-multilib
curl https://sh.rustup.rs -sSfo rustup-init.sh
chmod +x rustup-init.sh
echo "1111"
./rustup-init.sh -y
echo "2222"
curl "https://github.com/$AUXTOOLS_REPO/archive/refs/tags/v$AUXTOOLS_VERSION.tar.gz" -o libauxtools.tar.gz
echo "2233"
tar -xf ./libauxtools.tar.gz
rm libauxtools.tar.gz
cd libauxtools
rustup -y target add i686-unknown-linux-gnu
echo "3333"
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install build-essential g++-multilib libc6-i386 libstdc++6:i386
export PKG_CONFIG_ALLOW_CROSS=1
cargo build --release --target i686-unknown-linux-gnu
chmod +x ~/.byond/bin/libauxtools/target/i686-unknown-linux-gnu/release/libauxtools.so
ldd ~/.byond/bin/libauxtools/target/i686-unknown-linux-gnu/release/libauxtools.so

#!/bin/sh
set -e

# Determine architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ASSET_NAME="spotifyd-linux-x86_64-slim.tar.gz"
elif [ "$ARCH" = "aarch64" ]; then
  ASSET_NAME="spotifyd-linux-aarch64-slim.tar.gz"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Use the GitHub API to get the latest release info and re-encode the JSON
LATEST_RELEASE=$(curl -s 'https://api.github.com/repos/spotifyd/spotifyd/releases/latest')

# Extract the download URL for the correct architecture asset
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | jq -r --arg ASSET "$ASSET_NAME" \
  '.assets[] | select(.name==$ASSET) | .browser_download_url')

# Get version for logging purposes
VERSION=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')
echo "Installing spotifyd $VERSION for $ARCH"

# Download the Spotifyd archive
curl -L -o /tmp/spotifyd.tar.gz "$DOWNLOAD_URL"

# Extract the archive and move the binary to /usr/bin
tar xaf /tmp/spotifyd.tar.gz -C /tmp
chmod +x /tmp/spotifyd
mv -v /tmp/spotifyd /usr/bin/spotifyd

# Verify that spotifyd runs properly
/usr/bin/spotifyd --version

# Clean up downloaded archive
rm -v /tmp/spotifyd.tar.gz


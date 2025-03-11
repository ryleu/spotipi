FROM registry.fedoraproject.org/fedora-minimal:latest

# Update and install necessary packages, such as curl, jq, tar, bash,
# ca-certificates, and alsa-lib
RUN microdnf update -y && \
    microdnf install -y curl jq tar bash ca-certificates alsa-lib gzip && \
    microdnf clean all

# Create config directory for spotifyd configuration
RUN mkdir -p /config

# Install spotifyd
COPY install_spotifyd.sh /tmp/install_spotifyd.sh
RUN chmod +x /tmp/install_spotifyd.sh && \
    /tmp/install_spotifyd.sh && \
    rm -v /tmp/install_spotifyd.sh

# Copy the default spotifyd config
RUN mkdir -p /config
COPY spotifyd.conf /config/spotifyd.conf

# Expose /config as a volume for persistent configuration
VOLUME /config

# Default command: run spotifyd without daemon mode,
# using the configuration file from /config/spotifyd.conf.
CMD ["/usr/bin/spotifyd", "--no-daemon", "--config-path", "/config/spotifyd.conf"]


# MikroTik Netinstall Alternative for ARM Macs
# Uses native TFTP + DHCP server (no Wine needed)

FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    dnsmasq \
    tftp-hpa \
    bash \
    curl \
    iproute2 \
    iputils \
    busybox-extras

# Create working directories
WORKDIR /netinstall
RUN mkdir -p /tftpboot /var/lib/misc

# Copy configuration script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 67/udp 69/udp

CMD ["/entrypoint.sh"]

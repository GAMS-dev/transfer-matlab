
FROM fedora:latest

RUN yum -y update && \
    yum -y install gcc-c++ redhat-rpm-config octave octave-devel && \
    yum clean all

# install gitlab release-cli
RUN curl -L --output /usr/local/bin/release-cli \
    "https://release-cli-downloads.s3.amazonaws.com/latest/release-cli-linux-amd64" && \
    sudo chmod +x /usr/local/bin/release-cli

VOLUME /home

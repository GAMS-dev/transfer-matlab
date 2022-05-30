# Build from the MATLAB base image
FROM mathworks/matlab:r2022a

RUN sudo apt-get update && \
    sudo apt-get -y install git build-essential expect zip graphviz && \
    sudo apt-get -y install octave liboctave-dev doxygen && \
    sudo apt-get -y clean

COPY runmatlab.sh ./

# install gitlab release-cli
RUN sudo curl -L --output /usr/local/bin/release-cli \
    "https://release-cli-downloads.s3.amazonaws.com/latest/release-cli-linux-amd64" && \
    sudo chmod +x /usr/local/bin/release-cli

# entrypoint from matlab base image
ENTRYPOINT ["/bin/run.sh", "-shell"]

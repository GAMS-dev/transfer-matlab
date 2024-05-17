# Build from the MATLAB base image
FROM mathworks/matlab:r2023a

RUN sudo apt-get update && sudo apt-get -y install git zip && sudo apt-get -y clean

RUN sudo apt-get update && sudo apt-get -y install octave liboctave-dev && sudo apt-get -y clean

RUN sudo apt-get update && sudo apt-get -y install doxygen graphviz && sudo apt-get -y clean

RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install expect && sudo apt-get -y clean

COPY runmatlab.sh ./

# install gitlab release-cli
RUN sudo curl -L --output /usr/local/bin/release-cli \
    "https://release-cli-downloads.s3.amazonaws.com/latest/release-cli-linux-amd64" && \
    sudo chmod +x /usr/local/bin/release-cli

# install github-release tool
RUN wget https://cloud.gams.com/s/NJ26xfETjadAC23/download/github-release-binaries.zip  &&  \
    sudo mkdir -p /opt/github-release                                                   &&  \
    unzip github-release-binaries.zip                                                   &&  \
    chmod u+x leg-github-release                                                        &&  \
    sudo mv leg-github-release /opt/github-release/github-release                       &&  \
    rm deg-github-release wei-github-release.exe

# entrypoint from matlab base image
ENTRYPOINT ["/bin/run.sh", "-shell"]

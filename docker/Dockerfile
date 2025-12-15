FROM --platform=linux/amd64 amazonlinux:2

# Install dependencies for Amazon Linux 2
RUN yum update -y && yum install -y \
    ca-certificates curl git gcc gcc-c++ make \
    ncurses-devel libarchive-devel libffi-devel python2 \
    pkgconfig openssl-devel zlib-devel \
    sudo procps which tar unzip zip patch \
    autoconf213 nspr-devel \
    && yum clean all

ENV SBBS_HOME=/home/sbbs/sbbs \
    SBBS_USER=sbbs \
    SBBS_REPO=https://github.com/SynchronetBBS/sbbs.git \
    SBBS_BRANCH=dailybuild_linux-x64 \
    SBBSDIR=/home/sbbs/sbbs

# Create sbbs user and directories
RUN useradd -m -s /bin/bash sbbs && \
    mkdir -p /home/sbbs/sbbs && chown -R sbbs:sbbs /home/sbbs

WORKDIR /home/sbbs

USER sbbs

# Clone repo (shallow)
RUN git clone --depth 1 --branch ${SBBS_BRANCH} ${SBBS_REPO} repo

WORKDIR /home/sbbs/repo

# Build third-party dependencies and Synchronet BBS
RUN echo "Building third-party dependencies..." && \
    cd /home/sbbs/repo/3rdp/build && \
    make -j$(nproc) jslib cryptlib 2>&1 | tee /tmp/3rdp_build.log && \
    echo "Third-party build completed with exit code: $?" && \
    echo "Building Synchronet BBS..." && \
    cd /home/sbbs/repo/src/sbbs3 && \
    make -j$(nproc) RELEASE=1 2>&1 | tee /tmp/sbbs_build.log && \
    echo "SBBS build completed with exit code: $?" && \
    echo "Installing Synchronet..." && \
    cd /home/sbbs/repo && \
    make -f install/install-sbbs.mk run && \
    make -f install/install-sbbs.mk RELEASE=1 SYMLINK=1 NOCAP=1

# Ensure ownership
USER root
RUN chown -R sbbs:sbbs /home/sbbs

# Expose common SBBS ports
EXPOSE 23 64 80 128 443 8080 1123 11235 1883 1884 8883 8884

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER sbbs
WORKDIR /home/sbbs
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
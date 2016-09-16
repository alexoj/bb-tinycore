from ubuntu:trusty

run apt-get update && apt-get install -y --no-install-recommends \
	build-essential bison libncurses5 libncurses5-dev autoconf \
	gperf flex texinfo wget gawk libtool automake expat libexpat1-dev \
	bc fakeroot pkg-config dosfstools git curl ca-certificates \
	xutils-dev \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

run rm -f /bin/sh && ln -s /bin/bash /bin/sh

run echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

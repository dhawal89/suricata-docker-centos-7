FROM centos:7
MAINTAINER Dhawal K. Naik <naik.dhawal89@gmail.com>

#Metadata
LABEL program=suricata-ids

# Specify container username e.g. training, demo
ENV VIRTUSER dhawal

# Specify program
ENV PROG suricata

# Specify Suricata version to download and install (e.g. 2.0.9)
ENV VERS 4.0.4

# Install directory
ENV PREFIX /opt

# Path should include prefix
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/bin:/sbin:/bin:$PREFIX/bin

#Install general tools
RUN yum -y install sudo wget gawk git vim
RUN yum -y install libcap2-bin curl
RUN yum -y install lsof htop dstat sysstat iotop strace ltrace

#User config
RUN adduser --disable-password --gecos "" $VIRTUSER

#Password
RUN echo "$VIRTUSER:$VIRTUSER" | chpasswd
RUN echo "root:dhawal" | chpassword

#Sudo
RUN usermod -aG sudo $VIRTUSER

# Install dependencies
RUN yum update -y
RUN yum upgrade --security -y
RUN yum -y install epel-release
RUN yum -y install gcc \
                libpcap-devel \
                pcre-devel \
                file-devel \
                libyaml-devel \
                zlib-devel \
                jansson-devel \
                nss-devel \
                libpcap-ng-devel \
                libnet-devel \
                tar \
                make \
                libnetfilter_queue-devel \
                lua-devel

# Compile and install suricata
USER $VIRTUSER
WORKDIR /home/$VIRTUSER
RUN wget https://www.openinfosecfoundation.org/download/$PROG-$VERS.tar.gz
RUN tar -xvzf $PROG-$VERS.tar.gz
WORKDIR /home/$VIRTUSER/$PROG-$VERS
RUN ./configure --prefix=$PREFIX \
--sysconfdir=/etc --localstatedir=/var \
--enable-nfqueue --enable-lua --enable-debug 
RUN make
USER root
RUN make install && make install-full
RUN ldconfig
RUN chmod u+s $PREFIX/bin/$PROG

# Cleanup
RUN rm -rf /home/$VIRTUSER/$PROG-$VERS

# Environment
WORKDIR /home/$VIRTUSER
USER dhawal

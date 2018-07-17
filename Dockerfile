FROM ubuntu:16.04
LABEL maintainer Victor Liu, packerliu@gmail.com

RUN apt-get update && apt-get upgrade -y && apt-get autoremove

RUN apt-get install -y git wget apt-utils unzip

RUN apt-get install -y --reinstall lsb-release

RUN apt-get install -y gcc g++ make automake autoconf libtool
RUN apt-get install -y maven python
RUN apt-get install -y software-properties-common
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#RUN apt-get install -y --reinstall ca-certificates
#RUN mkdir /usr/local/share/ca-certificates/cacert.org
#RUN wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt
#RUN update-ca-certificates
#RUN git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
#RUN git config --global http.sslverify false
#RUN cd ~ && GIT_SSL_NO_VERIFY=true git clone https://github.com/batfish/batfish.git

COPY batfish-master.zip /root/.
RUN cd /root && unzip batfish-master.zip && mv batfish-master batfish
# disable wget to check certificate
RUN echo "check_certificate = off \nquiet = on" >> ~/.wgetrc
RUN cd /root/batfish && tools/install_z3_ubuntu.sh /usr
RUN cd /root/batfish && \
        /bin/bash -c "source tools/batfish_functions.sh && \
                batfish_build_all && \
                allinone -cmdfile tests/basic/commands"
CMD cd /root/batfish && \
        /bin/bash -c "source tools/batfish_functions.sh && \
                allinone -runclient false" 

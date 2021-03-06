FROM centos:8

# PROXY: uncomment if behind a proxy (px proxy server on localhost:3128)
# ENV http_proxy=http://host.docker.internal:3128
# ENV https_proxy=${http_proxy}
# ENV HTTP_PROXY=${http_proxy}
# ENV HTTPS_PROXY=${http_proxy}
ENV NO_PROXY=localhost,127.0.0.1

ENV MAVEN_VERSION=3.8.1 
ENV MAVEN_BASE_URL="https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries" 
ENV MAVEN_TARBALL="apache-maven-${MAVEN_VERSION}-bin.tar.gz" 
ENV MAVEN_HOME=/opt/maven 
ENV M2_HOME=${MAVEN_HOME} 
ENV MAVEN_CONFIG="${MAVEN_HOME}/.m2"

COPY ./config/maven/settings_noproxy.xml /tmp/settings_noproxy.xml
# COPY ./config/maven/settings_pxproxy.xml /tmp/settings_pxproxy.xml

# maven
RUN mkdir -p ${MAVEN_HOME} ${MAVEN_HOME}/ref \
    && curl -o /tmp/${MAVEN_TARBALL} ${MAVEN_BASE_URL}/${MAVEN_TARBALL} \
    && tar -xf /tmp/${MAVEN_TARBALL} -C ${MAVEN_HOME} --strip 1 \
    && ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn \
    # PROXY: use the correct maven settings if behind a proxy or not
    #&& cp /tmp/settings_pxproxy.xml ${MAVEN_HOME}/conf/settings.xml 
    && cp /tmp/settings_noproxy.xml ${MAVEN_HOME}/conf/settings.xml 

# tools
RUN yum -y install dnf-plugins-core
RUN dnf config-manager --set-enabled powertools
RUN dnf -y install gcc \
    && dnf -y install libstdc++-static \
    && dnf -y install glibc-devel zlib-devel \
    # ps
    && dnf -y install procps \
    # python
    && dnf -y install python3 \
    && dnf -y install python3-devel \
    # psrecord
    && pip3 install psrecord \
    && pip3 install matplotlib \
    && pip3 install flask \
    && pip3 install psycopg2-binary

COPY graalvm-ee-java11-linux-amd64-21.1.0.tar.gz /work/graalvm-ee-java11-linux-amd64-21.1.0.tar.gz
COPY native-image-installable-svm-svmee-java11-linux-amd64-21.1.0.jar /work/native-image-installable-svm-svmee-java11-linux-amd64-21.1.0.jar

# jabba with jdks
RUN curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh \
    && jabba install graalvm-ce@21.1.0-java11=tgz+https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.1.0/graalvm-ce-java11-linux-amd64-21.1.0.tar.gz \
    && jabba use graalvm-ce@21.1.0-java11 \
    && gu install native-image \
    && jabba install graalvm-ee@21.1.0-java11=tgz+file:///work/graalvm-ee-java11-linux-amd64-21.1.0.tar.gz \
    && jabba use graalvm-ee@21.1.0-java11 \
    && gu -L install /work/native-image-installable-svm-svmee-java11-linux-amd64-21.1.0.jar \
    && jabba alias default graalvm-ce@21.1.0-java11

COPY ./psrecord-patch/main.py /usr/local/lib/python3.6/site-packages/psrecord/

# apache benchmarking tool 
RUN dnf -y install httpd-tools

WORKDIR /work
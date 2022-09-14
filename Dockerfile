#FOR JENKINS
FROM centos:7.9.2009

RUN yum install -y -q ncurses fontconfig git openssl

ADD ./jdk-11.0.12_linux-x64_bin.tar.gz /opt/java
ADD ./jdk-8u60-linux-x64.gz /opt/java
ADD ./apache-maven-3.8.3-bin.tar.gz /opt/maven

RUN chown -R root:root /opt/java

RUN rm -rf /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

RUN update-alternatives --install /usr/bin/java java /opt/java/jdk-11.0.12/jre/bin/java 1 && \
    update-alternatives --install /usr/bin/javac javac /opt/java/jdk-11.0.12/bin/javac 1 && \
    update-alternatives --install /usr/bin/javaws javaws /opt/java/jdk-11.0.12/bin/javaws 1 && \
    update-alternatives --set java /opt/java/jdk-11.0.12/jre/bin/java && \
    update-alternatives --set javac /opt/java/jdk-11.0.12/bin/javac && \
    update-alternatives --set javaws /opt/java/jdk-11.0.12/bin/javaws

ENV JAVA_HOME=/opt/java/jdk-11.0.12
ENV PATH="$JAVA_HOME/bin:${PATH}"
RUN export JAVA_HOME

ENV JRE_HOME=/opt/java/jdk-11.0.12/jre
ENV PATH="$JRE_HOME/bin:${PATH}"
RUN export JRE_HOME

ENV JENKINS_HOME=/opt/jenkins/jenkins_home
ENV PATH="$JENKINS_HOME/bin:${PATH}"
RUN export JENKINS_HOME

ENV MAVEN_HOME=/opt/maven/apache-maven-3.8.3
ENV PATH="$MAVEN_HOME/bin:${PATH}"
RUN export MAVEN_HOME

ENV M2_HOME=/opt/maven/apache-maven-3.8.3
ENV PATH="$M2_HOME/bin:${PATH}"
RUN export M2_HOME

RUN mkdir -pv /opt/jenkins/jenkins_home/certs

WORKDIR /opt/jenkins/jenkins_home/certs

RUN openssl genrsa -passout pass:Passw0rd -out jenkins.key 4096 && \
    openssl req -x509 -new -nodes -key jenkins.key -sha256 -subj "/C=IN/ST=Karnataka/L=Bengaluru/O=CC/CN=git-doc" -out jenkins.crt && \
    openssl pkcs12 -passout pass:Passw0rd -export -out jenkins.p12 -inkey jenkins.key -in jenkins.crt -certfile jenkins.crt -name jenkins && \
    /opt/java/jdk1.8.0_60/jre/bin/keytool -importkeystore -srckeystore jenkins.p12 -srcstorepass 'Passw0rd' -srcstoretype PKCS12 -srcalias jenkins -deststoretype JKS -destkeystore jenkins.jks -deststorepass 'Passw0rd' -destalias jenkins

WORKDIR /opt/jenkins
    
COPY ./jenkins.war /opt/jenkins

#CMD ["java", "-jar", "jenkins.war"]
CMD ["java", "-jar", "jenkins.war", "--httpPort=-1", "--httpsPort=8443", "--httpsKeyStore=/opt/jenkins/jenkins_home/certs/jenkins.jks", "--httpsKeyStorePassword=Passw0rd"]

#######################################################################
# Creates a base image with JBoss EAP-6.4                             #
#######################################################################

# Use 
FROM registry.access.redhat.com/jboss-webserver-3/tomcat8-openshift

USER root

ENV APPDYNAMICS_AGENT_VERSION 4.1.7.1
ENV APPDYNAMICS_URL https://packages.appdynamics.com/java

COPY AppServerAgent.zip /tmp/AppServerAgent.zip

RUN mkdir -p /opt/java-agent && \
    unzip -q /tmp/AppServerAgent.zip -d /opt/java-agent && \
    chmod -R 777 /opt/java-agent/ver$APPDYNAMICS_AGENT_VERSION && \
    rm -rf /tmp/AppServerAgent.zip

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./sti/bin/ /usr/local/sti
RUN chmod -R 755 /usr/local/sti

#COPY cacerts.jks /opt/java-agent/ver4.1.7.1/conf/cacerts.jks

COPY DigiCertGlobalRootCA /tmp/DigiCertGlobalRootCA
COPY DigiCertSHA2SecureServerCA /tmp/DigiCertSHA2SecureServerCA
COPY saas.appdynamics.com.cer /tmp/saas.appdynamics.com.cer

RUN keytool --importcert --noprompt -trustcacerts -alias AppRootCA -file /tmp/DigiCertGlobalRootCA -keystore /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.45-30.b13.el7_1.x86_64/jre/lib/security/cacerts -storepass changeit
RUN keytool --importcert --noprompt -trustcacerts -alias AppdSecureCA -file /tmp/DigiCertSHA2SecureServerCA -keystore /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.45-30.b13.el7_1.x86_64/jre/lib/security/cacerts -storepass changeit
RUN keytool --importcert --noprompt -trustcacerts -alias AppCert -file /tmp/saas.appdynamics.com.cer -keystore /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.45-30.b13.el7_1.x86_64/jre/lib/security/cacerts -storepass changeit

#RUN cp /etc/pki/java/cacerts /opt/java-agent/ver4.1.7.1/conf/cacerts

COPY controller-info.xml /opt/java-agent/ver4.1.7.1/conf/controller-info.xml

#RUN chmod -R 777 /opt/java-agent/ver4.1.7.1/conf/cacerts.jks

#RUN chmod -R 777 /opt/java-agent/ver4.1.7.1/conf/cacerts

RUN chmod -R 777 /opt/java-agent/ver4.1.7.1/conf/controller-info.xml

##########################################################
# Create jboss user
##########################################################

# add our user 
#RUN $JBOSS_HOME/bin/add-user.sh -g admin -u admin -p admin-123 -s

EXPOSE 8080 4447 9990

USER 185


CMD /usr/local/sti/usage

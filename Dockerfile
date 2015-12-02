#######################################################################
# Creates a base image with JBoss EAP-6.4                             #
#######################################################################

# Use 
FROM registry.access.redhat.com/jboss-webserver-3/tomcat7-openshift

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


##########################################################
# Create jboss user
##########################################################

# add our user 
#RUN $JBOSS_HOME/bin/add-user.sh -g admin -u admin -p admin-123 -s

EXPOSE 8080 4447 9990

USER jboss


CMD /usr/local/sti/usage

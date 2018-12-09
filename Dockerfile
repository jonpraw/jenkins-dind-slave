FROM docker:stable-dind
MAINTAINER jonpraw <jonpraw@aol.com>

# Set environment variables
ENV JENKINS_HOME /home/jenkins
ENV JENKINS_REMOTING_VERSION 3.9
ENV DOCKER_HOST tcp://0.0.0.0:2375

# Install requirements
RUN apk --update --no-cache add \
    curl \
    bash \
    openjdk8-jre-base \
    sudo \
    && rm -rf /var/cache/apk/*

# Add jenkins user and allow to run docker as root
RUN adduser -D -h $JENKINS_HOME -s /bin/sh jenkins jenkins \
    && chmod a+rwx $JENKINS_HOME \
    && echo "jenkins ALL=(ALL) NOPASSWD: /usr/local/bin/dockerd" > /etc/sudoers.d/00jenkins \
    && chmod 440 /etc/sudoers.d/00jenkins \
    && echo "jenkins ALL=(ALL) NOPASSWD: /usr/local/bin/docker" > /etc/sudoers.d/01jenkins \
    && chmod 440 /etc/sudoers.d/01jenkins

# Install Jenkins Remoting agent
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# Copy slave-entrypoint
USER jenkins
COPY slave-entrypoint /usr/local/bin/slave-entrypoint

# Make slave-entrypoint executable
USER root
RUN chmod +x /usr/local/bin/slave-entrypoint \
  && chown root:jenkins /usr/local/bin/docker

# Init
USER jenkins
VOLUME $JENKINS_HOME
WORKDIR $JENKINS_HOME
RUN mkdir $JENKINS_HOME/.docker

ENTRYPOINT ["slave-entrypoint"]
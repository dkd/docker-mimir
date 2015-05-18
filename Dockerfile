FROM dockerfile/java:oracle-java7
MAINTAINER Johannes Goslar

ENV ANT_HOME /usr/local/ant
WORKDIR $ANT_HOME/..

ENV ANT_MINOR_VERSION 1.9.4
RUN wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_MINOR_VERSION}-bin.tar.gz && \
tar zxf apache-ant-*.tar.gz && \
rm apache-ant-*.tar.gz && \
mv apache-ant-* ant

ENV PATH $ANT_HOME/bin:$PATH

RUN apt-get update \
&& apt-get install -y subversion \
&& rm -rf /var/lib/apt/lists/*

ENV MIMIRREVISION 18595
RUN mkdir /app/ \
&& cd /app \
&& svn checkout -r$MIMIRREVISION http://svn.code.sf.net/p/gate/code/mimir/trunk mimir

ENV GRAILSREVISION 2.2.3
RUN wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-$GRAILSREVISION.zip 
RUN unzip grails-*.zip \
&& rm -rf grails-*.zip
RUN ln -s grails-$GRAILSREVISION grails
ENV GRAILS_HOME /usr/local/grails
ENV PATH $GRAILS_HOME/bin:$PATH
RUN grails help

WORKDIR /app/mimir
RUN ant
WORKDiR /app/mimir/mimir-cloud/
RUN grails prod compile
ENV GRAILS_OPTS -Dgrails.server.port.http=8091
ENV JAVA_OPTS -Xms128m -Xmx1024m -XX:PermSize=64m -XX:MaxPermSize=256m
EXPOSE 8091

RUN mkdir /app/indexes/ \
&& chmod 666 /app/indexes

ADD mimir-config.groovy /etc/mimir/mimir-local.groovy
ADD FIBootStrap.groovy /app/mimir/mimir-cloud/grails-app/conf/

VOLUME /app/indexes /app/db
RUN sed -i s/file\\:prodDb/file\\:\\/app\\/db\\/prodDb/g /app/mimir/mimir-cloud/grails-app/conf/DataSource.groovy \
&& cat  /app/mimir/mimir-cloud/grails-app/conf/DataSource.groovy

CMD ["grails", "prod", "RunApp"]    

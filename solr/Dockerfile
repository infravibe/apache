
ARG SOLR_VERSION=8
FROM solr:${SOLR_VERSION}
LABEL authors="akarshsahani@gmail.com"

USER 0

# Copy Ranger audit config set
RUN mkdir -p /opt/solr/server/solr/configsets/ranger_audits/conf
COPY config/solr-ranger_audits/* /opt/solr/server/solr/configsets/ranger_audits/conf/
RUN chown -R solr:solr /opt/solr/server/solr/configsets/ranger_audits/

# Copy Atlas collections config set
RUN mkdir -p /opt/solr/server/solr/configsets/atlas/conf/lang
COPY ./config/solr/*.*        /opt/solr/server/solr/configsets/atlas/conf/
COPY ./config/solr/lang/*.*   /opt/solr/server/solr/configsets/atlas/conf/lang/
RUN chown -R solr:solr /opt/solr/server/solr/configsets/atlas/

# Copy Atlas collection creation script
COPY ./scripts/atlas-solr-create.sh /docker-entrypoint-initdb.d/

EXPOSE 8983

USER solr

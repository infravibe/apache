FROM apache/hive:4.0.1
LABEL authors="akarshsahani@gmail.com"

# Set environment variables
ENV HIVE_HOME=/opt/hive \
    HIVE_CONF_DIR=/opt/hive/conf \
    ATLAS_VERSION=2.4.0 \
    ATLAS_HOOK_DIR=/opt/atlas/hook/hive \
    ATLAS_CONF_FILE=atlas-application.properties \
    RANGER_HIVE_PLUGIN_CONFIG_FILE=ranger-hive-plugin-install.properties \
    RANGER_HIVE_PLUGIN_VERSION=3.0.0-SNAPSHOT \
    RANGER_HOME=/opt/ranger

# Copy the Atlas Hive Hook tarball and configuration file
COPY /conf/atlas/apache-atlas-${ATLAS_VERSION}-hive-hook.tar.gz /tmp/
COPY /conf/atlas/${ATLAS_CONF_FILE} /tmp/${ATLAS_CONF_FILE}
COPY /conf/ranger/ranger-${RANGER_HIVE_PLUGIN_VERSION}-hive-plugin.tar.gz /tmp/
COPY /conf/ranger/${RANGER_HIVE_PLUGIN_CONFIG_FILE} /tmp/

USER root

# Install Atlas Hive Hook
RUN mkdir -p /opt/atlas && \
    tar -xzf /tmp/apache-atlas-${ATLAS_VERSION}-hive-hook.tar.gz -C /opt/atlas && \
    mkdir -p ${ATLAS_HOOK_DIR} && \
    cp -r /opt/atlas/apache-atlas-hive-hook-${ATLAS_VERSION}/hook/hive/* ${ATLAS_HOOK_DIR}/ && \
    rm -rf /tmp/apache-atlas-${ATLAS_VERSION}-hive-hook.tar.gz /opt/atlas/apache-atlas-hive-hook-${ATLAS_VERSION}

# Copy Atlas config to Hive conf
RUN cp /tmp/${ATLAS_CONF_FILE} $HIVE_HOME/conf/

# Set Hive Auxiliary JAR path to include Atlas hook jars
ENV HIVE_AUX_JARS_PATH=${ATLAS_HOOK_DIR}

# Copy Atlas config to Hive conf
RUN cp /tmp/${ATLAS_CONF_FILE} $HIVE_HOME/conf/

# Set Hive Auxiliary JAR path and Hive conf dir
RUN echo "export HIVE_AUX_JARS_PATH=${HIVE_AUX_JARS_PATH}" >> $HIVE_HOME/conf/hive-env.sh && \
    echo "export HIVE_CONF_DIR=${HIVE_HOME}/conf" >> $HIVE_HOME/conf/hive-env.sh

# Install Ranger Hive plugin
RUN mkdir -p /opt/ranger && \
    tar -xzf /tmp/ranger-${RANGER_HIVE_PLUGIN_VERSION}-hive-plugin.tar.gz -C /opt/ranger && \
    ln -s /opt/ranger/ranger-${RANGER_HIVE_PLUGIN_VERSION}-hive-plugin /opt/ranger/ranger-hive-plugin && \
    rm -f /tmp/ranger-${RANGER_HIVE_PLUGIN_VERSION}-hive-plugin.tar.gz && \
    cp -f /tmp/${RANGER_HIVE_PLUGIN_CONFIG_FILE} /opt/ranger/ranger-hive-plugin/install.properties

#RUN chmod +x /opt/ranger/ranger-hive-plugin/enable-hive-plugin.sh \
#    && bash /opt/ranger/ranger-hive-plugin/enable-hive-plugin.sh

# Set user back to hive (if originally set that way)
USER hive

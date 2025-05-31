# Dockerfile
FROM apache/hadoop:3.3.6
LABEL authors="akarshsahani@gmail.com"

USER root

# Apply the patch by changing the incorrect line
RUN sed -i 's/for key, val in props:/for key, val in props.items():/' /opt/transformation.py

USER hadoop


#3.
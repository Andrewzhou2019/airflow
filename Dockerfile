# Base Image
FROM python:3.7-slim-buster

# Arguments that can be set with docker build
ARG AIRFLOW_VERSION=1.10.1
ARG AIRFLOW_HOME=/usr/local/airflow

# Export the environment variable AIRFLOW_HOME where airflow will be installed
ENV AIRFLOW_HOME=${AIRFLOW_HOME}

ENV AIRFLOW_GPL_UNIDECODE=1

# Install dependencies and tools
RUN apt-get update -yqq && \
    apt-get upgrade -yqq && \
    apt-get install -yqq --no-install-recommends \
    wget \
    libczmq-dev \
    curl \
    libssl-dev \
    git \
    inetutils-telnet \
    bind9utils freetds-dev \
    libkrb5-dev \
    libsasl2-dev \
    libffi-dev libpq-dev \
    freetds-bin build-essential \
    default-libmysqlclient-dev \
    apt-utils \
    rsync \
    zip \
    unzip \
    gcc \
    locales \
    procps \
    && apt-get clean

# Load custom configuration
COPY ./airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

# Upgrade pip
# Create airflow user
# Install apache airflow with subpackages
RUN pip install --upgrade pip && \
    useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow && \
    pip install apache-airflow==${AIRFLOW_VERSION} 
#--constraint "https://raw.githubusercontent.com/apache/airflow/constraints-1.10.1/constraints-3.7.txt"

# Copy the entrypoint.sh from host to container (at path AIRFLOW_HOME)
COPY ./entrypoint.sh /entrypoint.sh

# Set the entrypoint.sh file to be executable
RUN chmod +x ./entrypoint.sh

# Set the owner of the files in AIRFLOW_HOME to the user airflow
RUN chown -R airflow: ${AIRFLOW_HOME}

# Set the username to use
USER airflow

# Set workdir (it's like a cd inside the container)
WORKDIR ${AIRFLOW_HOME}

# Create the dags folder which will contain the DAGs
RUN mkdir dags

# Expose the webserver port
EXPOSE 8181

# Execute the entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
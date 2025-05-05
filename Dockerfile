FROM ubuntu:20.04

RUN groupadd -r backupgroup && useradd -r -g backupgroup backupuser

RUN apt update \
    && apt install python python3-pip gnupg wget -y \
    && pip3 install s3cmd

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt update \
    && apt install postgresql-client-17 -y

COPY ./s3cfg /.s3cfg
COPY ./backup.sh /

RUN chown backupuser:backupgroup /.s3cfg /backup.sh \
    && chmod 600 /.s3cfg /backup.sh

RUN mkdir -p /home/backupuser \
    && ln -s /.s3cfg /home/backupuser/.s3cfg

RUN mkdir /opt/PGbackup \
    && chown backupuser:backupgroup /opt/PGbackup

USER backupuser

ENV DATACENTER_REGION=AMS3 \
    ACCESS_KEY= \
    SECRET_KEY= \
    ENCRYPTION_PASSWORD=

WORKDIR /opt

CMD ["bash", "-x", "/backup.sh"]

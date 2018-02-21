FROM debian:stretch

ENV CT_VERSION=0.7.0 CT_SHA256=dca78785b487ad4fae135699ca0f48aa95ce736b0a67c2ec6bdc14ca4cbe05c4
ENV STRIKE_SRV_DIR=/srv/strike
ENV GUNICORN_BIND=0.0.0.0:5000
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

EXPOSE 5000
WORKDIR /var/lib/strike
ENTRYPOINT ["/usr/local/bin/launch.sh"]

COPY app/ .
COPY launch.sh /usr/local/bin/

ADD https://github.com/coreos/container-linux-config-transpiler/releases/download/v${CT_VERSION}/ct-v${CT_VERSION}-x86_64-unknown-linux-gnu ./bin/ct

RUN apt-get -y update > /dev/null && \
    apt-get -y upgrade > /dev/null && \
    apt-get -y install \
        python3 \
        python3-pip > /dev/null && \
    pip3 install --no-cache-dir -r requirements.txt && \
    echo "$CT_SHA256  ./bin/ct" | sha256sum -c && \
    chmod +x ./bin/ct /usr/local/bin/launch.sh

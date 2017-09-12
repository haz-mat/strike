FROM debian:stretch

WORKDIR /var/lib/strike

ENV CT_VERSION=0.4.2 FLASK_APP=strike.py STRIKE_SRV_DIR=/srv/strike LC_ALL=C.UTF-8 LANG=C.UTF-8

COPY app/ .

ADD https://github.com/coreos/container-linux-config-transpiler/releases/download/v${CT_VERSION}/ct-v${CT_VERSION}-x86_64-unknown-linux-gnu ./bin/ct

RUN apt-get -y update > /dev/null && \
    apt-get -y upgrade > /dev/null && \
    apt-get -y install \
        python3 \
        python3-pip > /dev/null && \
    pip3 install --no-cache-dir -r requirements.txt && \
    chmod +x ./bin/ct

ENTRYPOINT ["/usr/local/bin/flask"]

CMD ["run", "--host=0.0.0.0"]

EXPOSE 5000

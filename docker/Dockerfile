FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
        tar \
        gzip \
        lib32gcc-s1 \
        openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/steamcmd /opt/necesse /data \
    && curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
        | tar -C /opt/steamcmd -xzvf - \
    && /opt/steamcmd/steamcmd.sh +login anonymous +force_install_dir /opt/necesse +app_update 1169370 validate +quit

VOLUME ["/data"]

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 14159/udp

WORKDIR /opt/necesse

ENTRYPOINT ["/entrypoint.sh"]

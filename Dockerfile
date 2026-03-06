# MyAAC web panel: nginx + PHP-FPM only (no TFS)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    nginx \
    php8.3-fpm \
    php8.3-mysql \
    php8.3-gd \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-curl \
    php8.3-zip \
    && rm -rf /var/lib/apt/lists/*

COPY nginx/default.conf /etc/nginx/template.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN useradd -m -u 988 container
USER container

WORKDIR /home/container

ENTRYPOINT ["/entrypoint.sh"]

FROM php:8.4-fpm

ARG ORACLE_VERSION=11.2.0.4.0
ARG ORACLE_DIR=instantclient_11_2
ARG ORACLE_LIB_VER=11.1

# 1. Системные зависимости
# libpq-dev — для PostgreSQL, default-libmysqlclient-dev — для MySQL (опционально, но надёжно)
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    autoconf \
    build-essential \
    libpq-dev \
    default-libmysqlclient-dev \
    && (apt-get install -y libaio1t64 || apt-get install -y libaio1) \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install zip gd \
    && rm -rf /var/lib/apt/lists/*

# 2. Установка Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Фикс libaio для Debian Trixie (критично для Oracle)
RUN if [ ! -f /usr/lib/x86_64-linux-gnu/libaio.so.1 ]; then \
        find /usr -name "libaio.so.*" -type f | head -1 | xargs -I {} ln -sf {} /usr/lib/x86_64-linux-gnu/libaio.so.1; \
    fi \
    && ldconfig

WORKDIR /opt/oracle

# 3. Oracle Instant Client 11.2
RUN wget -q https://raw.githubusercontent.com/dockette/oracle-instantclient/master/instantclient-basic-linux.x64-${ORACLE_VERSION}.zip \
    && wget -q https://raw.githubusercontent.com/dockette/oracle-instantclient/master/instantclient-sdk-linux.x64-${ORACLE_VERSION}.zip \
    && unzip -q instantclient-basic-linux.x64-${ORACLE_VERSION}.zip \
    && unzip -q instantclient-sdk-linux.x64-${ORACLE_VERSION}.zip \
    && rm -f *.zip \
    && ln -s /opt/oracle/${ORACLE_DIR} /opt/oracle/instantclient \
    && ln -s /opt/oracle/instantclient/libclntsh.so.${ORACLE_LIB_VER} /opt/oracle/instantclient/libclntsh.so \
    && ln -s /opt/oracle/instantclient/liboccii.so.${ORACLE_LIB_VER} /opt/oracle/instantclient/liboccii.so \
    && ln -sf /opt/oracle/instantclient/libnnz11.so /opt/oracle/instantclient/libnnz11.so.${ORACLE_LIB_VER}

ENV OCI_HOME=/opt/oracle/instantclient \
    LD_LIBRARY_PATH=/opt/oracle/instantclient:/usr/lib/x86_64-linux-gnu \
    PATH=${OCI_HOME}:${PATH} \
    NLS_LANG=RUSSIAN_RUSSIA.AL32UTF8

# 4. Стандартные расширения (MySQL, PostgreSQL)
RUN docker-php-ext-install pdo_mysql mysqli pdo_pgsql pgsql

# 5. Oracle расширения (PECL + GitHub)
RUN echo "instantclient,/opt/oracle/instantclient" | pecl install oci8-3.2.1 \
    && docker-php-ext-enable oci8

RUN cd /tmp \
    && git clone --depth 1 https://github.com/php/pecl-database-pdo_oci.git \
    && cd pecl-database-pdo_oci \
    && phpize \
    && ./configure --with-pdo-oci=instantclient,/opt/oracle/instantclient,11.1 \
    && make \
    && make install \
    && echo "extension=pdo_oci.so" > /usr/local/etc/php/conf.d/pdo_oci.ini \
    && cd / && rm -rf /tmp/pecl-database-pdo_oci

# 6. Финальная проверка
RUN php -r "if (!extension_loaded('oci8')) exit(1);" \
    && php -r "if (!extension_loaded('pdo_oci')) exit(1);" \
    && php -r "if (!extension_loaded('pdo_mysql')) exit(1);" \
    && php -r "if (!extension_loaded('pdo_pgsql')) exit(1);" \
    || (echo "ERROR: Some extensions not loaded!" && exit 1)

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/html
EXPOSE 9000
CMD ["php-fpm"]
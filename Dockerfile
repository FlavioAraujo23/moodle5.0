FROM php:8.1-apache

# Instalar dependências
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libicu-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libonig-dev \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensões PHP necessárias
RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    zip \
    gd \
    intl \
    xml \
    soap \
    opcache \
    mbstring \
    curl

# Configurar PHP
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'upload_max_filesize=1024M'; \
    echo 'post_max_size=1024M'; \
    echo 'memory_limit=1024M'; \
    echo 'max_input_vars=5000'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Baixar e extrair o Moodle 5.0
WORKDIR /var/www/html
RUN wget https://download.moodle.org/download.php/stable500/moodle-latest-500.tgz && \
    tar -xzf moodle-latest-500.tgz -C /var/www/html --strip-components=1 && \
    rm moodle-latest-500.tgz

# Criar diretório de dados
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/html /var/www/moodledata && \
    chmod -R 755 /var/www/html /var/www/moodledata

# Script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]

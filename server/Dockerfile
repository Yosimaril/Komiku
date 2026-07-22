FROM php:8.3-apache

RUN docker-php-ext-install mysqli

RUN a2enmod rewrite

RUN sed -i 's/AllowOverride None/AllowOverride All/g' \
    /etc/apache2/apache2.conf

COPY endpoint/ /var/www/html/

WORKDIR /var/www/html

EXPOSE 80

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
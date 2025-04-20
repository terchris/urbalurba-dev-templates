# filename: templates/php-basic-webserver/Dockerfile
# Multi-stage Dockerfile for PHP web application
#
# Build stage:
# - Uses PHP 8.2 as base image
# - Installs necessary extensions
# - Copies application files
#
# Run stage:
# - Uses PHP 8.2 with Apache
# - Configures Apache for PHP
# - Exposes port 3000

# Build stage
FROM php:8.2-cli AS build
WORKDIR /app
COPY app/ .
RUN docker-php-ext-install opcache

# Run stage
FROM php:8.2-apache
WORKDIR /var/www/html

# Copy built files from build stage
COPY --from=build /app/ .

# Configure Apache
RUN a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i 's/Listen 80/Listen 3000/g' /etc/apache2/ports.conf
RUN sed -i 's/:80/:3000/g' /etc/apache2/sites-enabled/000-default.conf

EXPOSE 3000
CMD ["apache2-foreground"] 
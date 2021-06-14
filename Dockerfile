FROM php:8.0.6-cli-alpine3.13

ARG LARAVEL_VERSION="8.*"

# We will delete this later, but need composer to setup the project.
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy the RoadRunner executable to our image.
COPY --from=spiralscout/roadrunner:2.2.1 /usr/bin/rr /usr/bin/rr

# Install Laravel extension requirements that did not come with the default image.
RUN apk add --no-cache libzip-dev
RUN docker-php-ext-install bcmath ctype pdo_mysql pcntl sockets

# Install Laravel and RoadRunner
WORKDIR /srv/laravel

RUN cd /srv && composer create-project laravel/laravel="${LARAVEL_VERSION}" laravel
RUN cd /srv/laravel && \
    composer require laravel/octane spiral/roadrunner && \
    php artisan octane:install --server="roadrunner"

RUN chown -R www-data:www-data /srv/laravel

# Remove the default directory and set our working directory.
RUN rm -rf /var/www

# WORKDIR /srv/laravel

USER www-data

# Run RoadRunner
CMD [ "php", "/srv/laravel/artisan", "octane:start", "--host=0.0.0.0" ]

# Expose the ports that RoadRunner usually uses.
EXPOSE 8000
EXPOSE 6001
EXPOSE 2114

# Check the health status using the status page RoadRunner gives us.
HEALTHCHECK CMD curl --fail http://localhost:2114/health?plugin=http || exit 1

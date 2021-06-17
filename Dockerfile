# Here we are going to install Laravel extension requirements that did not come
# with the default PHP image. This will be necessary for Laravel and RoadRunner.
FROM php:8.0-cli-alpine3.13 as php-base
    WORKDIR /srv/laravel

    RUN apk add --no-cache libzip-dev && \
        docker-php-ext-install bcmath ctype pdo_mysql pcntl sockets && \
        rm -rf /var/www && \
        chown -R www-data:www-data /srv/laravel

# This stage is so that we can build up everything that doesn't require Laravel
# so as to not bust the caching for those items.
FROM php-base as octane-base
    COPY --from=spiralscout/roadrunner:2.2.1 /usr/bin/rr /usr/bin/rr

    # This really shouldn't be modified, so we aren't advertising the env variable.
    # It allows us to globally install chokidar without modifying the Laravel package.json.
    ENV NODE_PATH "/home/www-data/.npm-global/lib/node_modules"

    RUN apk add --no-cache nodejs npm && \
        mkdir "/home/www-data/.npm-global/" && \
        npm config set prefix "/home/www-data/.npm-global/" && \
        npm install -g chokidar

# Here we have a build container so that it is not necessary to pull composer into
# the final container. We are going to create a new Laravel project and install Octane.
FROM php-base as laravel
    ARG LARAVEL_VERSION="8.*"

    COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

    RUN cd /srv && \
        composer create-project laravel/laravel="${LARAVEL_VERSION}" laravel && \
        cd /srv/laravel && \
        composer require laravel/octane spiral/roadrunner && \
        php artisan octane:install --server="roadrunner" && \
        rm "/srv/laravel/.env"

# This is our final container. We will install the RoadRunner binary and copy over
# our built version of Laravel.
FROM octane-base
    USER www-data

    COPY --from=laravel --chown=www-data:www-data /srv/laravel/ /srv/laravel/

    # Allow the user to specify RoadRunner options via ENV variables.
    ENV ROADRUNNER_MAX_REQUESTS "500"
    ENV ROADRUNNER_WATCH $false
    ENV ROADRUNNER_WORKERS "auto"

    # Expose the ports that Octane is using.
    EXPOSE 8000

    # Run RoadRunner
    CMD if [[ -z $ROADRUNNER_WATCH ]] ; then \
        php artisan octane:start --server="roadrunner" --host="0.0.0.0" --workers=${ROADRUNNER_WORKERS} --max-requests=${ROADRUNNER_MAX_REQUESTS} ; \
    else \
        php artisan octane:start --server="roadrunner" --host="0.0.0.0" --workers=${ROADRUNNER_WORKERS} --max-requests=${ROADRUNNER_MAX_REQUESTS} --watch ; \
    fi

    # Check the health status using the Octane status command.
    HEALTHCHECK CMD php artisan octane:status --server="roadrunner"

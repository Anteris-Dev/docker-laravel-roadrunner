# Laravel Roadrunner
This is a Docker container that runs Laravel Octane using [RoadRunner](https://roadrunner.dev/). This container is built nightly from the latest version of Laravel and pushed to the [Docker registry](https://hub.docker.com/r/anterisdev/laravel-roadrunner).

## Container Ports
This container serves RoadRunner on port 8000. You will want to expose this port when serving Laravel applications.

## Container Environment Variables
For security and convenience reasons, the `.env` file is removed from the container. You will need to ensure you pass a base64 key via the `APP_KEY` environment variable.

For example:

```bash
docker run -it -e "APP_ENV=base64:YXNkZmFzZGhmYXNkZmFzZGZhc2RmYWRz" -p 8000:8000 anterisdev/laravel-roadrunner:latest
```

This container also supports environment variables for controlling the behaviour of Octane.

- `ROADRUNNER_WATCH` - Pass any value to this environment variable to enable [watch mode](https://laravel.com/docs/8.x/octane#watching-for-file-changes). You will want to do this for development _but not production_.
- `ROADRUNNER_WORKERS` - Pass an integer to this environment variable to [set the number of workers](https://laravel.com/docs/8.x/octane#specifying-the-worker-count). By default this is set to 'auto'.

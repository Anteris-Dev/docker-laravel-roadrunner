
# Laravel Octane on RoadRunner

  

This Docker container runs Laravel on RoadRunner, using [Laravel Octane](https://github.com/laravel/octane). This container is built nightly from the latest version of Laravel and pushed to the [Docker registry](https://hub.docker.com/r/anterisdev/laravel-roadrunner).

## Usage

To quickly get up and running, you can use the following command to run the container. This will expose the Laravel application at [`http://localhost:8000`](http://localhost:8000).

>  **Note:** It is important to pass the environment variable `APP_KEY` to the container. For more information, see [here](https://laravel.com/docs/8.x/encryption#configuration).

```bash
docker run -it \
    -p 8000:8000 \
    -e "APP_KEY=base64:1RfxZT785MHjMkAsIouOaukQHk77Ov+/0Y95EfHmhA8=" \
    anterisdev/laravel-roadrunner:latest
```

If you would like to run your own Laravel application in this container, be sure to check out the [volumes](#volumes) section below.

## Ports

Laravel Octane runs RoadRunner on port `8000`. This is the only port that is currently exposed by the container.

## Environment Variables

Several environment variables expose configuration options for RoadRunner. These are listed below.

| Name | Value | Description |
|---|---|---|
| ROADRUNNER_MAX_REQUESTS | `int` | How many requests RoadRunner workers should handle before being gracefully restarted. For more information, see [here](https://laravel.com/docs/8.x/octane#specifying-the-max-request-count).
| ROADRUNNER_WATCH | `yes` | If this environment variable is passed, RoadRunner will be run in watch mode so that it auto-reloads changes to your application. This is something you will want to run during development. For more information, see [here](https://laravel.com/docs/8.x/octane#watching-for-file-changes).
| ROADRUNNER_WORKERS | `int` or `auto` | The number of workers that should be created to handle requests. For more information, see [here](https://laravel.com/docs/8.x/octane#specifying-the-worker-count).

## Volumes

You are probably looking to run your own Laravel application in this Docker container. To do so, you will need to inject your application code. The easiest way to do this is with a volume.

>  **Note**: There are a few prerequisites for this step. Make sure you have installed Laravel Octane in your application. By running:
>  ```bash
>  composer require laravel/octane spiral/roadrunner
>  php artisan install:octane --server="roadrunner"
>  ```
> For more information, see [here](https://laravel.com/docs/8.x/octane#installation).

The Laravel application files are stored at `/srv/laravel` in the Docker container. You will need to [mount](https://docs.docker.com/storage/volumes/) your application to that directory. A basic example of this can be seen below. Notice that we also added the `-e "ROADRUNNER_WATCH=yes"` option so that RoadRunner goes into watch mode.

```bash
docker run -it \
    -p 8000:8000 \
    -e "APP_KEY=base64:1RfxZT785MHjMkAsIouOaukQHk77Ov+/0Y95EfHmhA8=" \
    -e "ROADRUNNER_WATCH=yes" \
    --mount type=bind,source="$(pwd)"/my-laravel-app,target=/srv/laravel \
    anterisdev/laravel-roadrunner:latest
```

# Demo-api

Demo API powered by Node.js/Express.

## Running development server (with live-reloading)

1. Run the following commands in the app's root directory then submit requests to http://localhost:3000

```
yarn install
yarn run dev
```

## Running production version in Docker container
1. Run the following commands in the app's root directory then submit requests to http://localhost:YOUR_CONTAINER_PORT. YOUR_CONTAINER_ID will be returned by the `docker run` command and YOUR_CONTAINER_PORT will be returned by the `docker port` command.

```
docker build -t demo-api .
docker run -d -P demo-api
docker port YOUR_CONTAINER_ID
```

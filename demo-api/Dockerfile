FROM mhart/alpine-node:latest

RUN apk add --update python ca-certificates

RUN npm install -g yarn@0.17.3

WORKDIR /app

COPY package.json .
COPY yarn.lock .
RUN yarn install

COPY .babelrc .
COPY src src
RUN yarn run build

ENV NODE_ENV=production
ENV PORT=80

EXPOSE ${PORT}/tcp

ENTRYPOINT ["node", "--harmony", "dist"]

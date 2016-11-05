FROM node:7

RUN npm install -g yarn@0.16.1

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

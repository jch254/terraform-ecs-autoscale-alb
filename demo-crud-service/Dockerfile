FROM node:7

RUN npm install -g yarn@0.16.1

WORKDIR /app

COPY package.json .
RUN yarn install

COPY src src
RUN yarn run build

ENV NODE_ENV=production
ENV PORT=5000

EXPOSE ${PORT}

ENTRYPOINT ["node", "--", "harmony", "dist"]

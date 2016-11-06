import http from 'http';
import express from 'express';
import winston from 'winston';

import middleware from './middleware';
import healthcheck from './healthcheck';
import items from './items';
import { urlRewriter, topLevelErrorHandler } from './utils';

const app = express();

app.server = http.createServer(app);

if (process.env.NODE_ENV === 'production') {
  app.use(urlRewriter);
}

app.use(middleware());
app.use(healthcheck());
app.use(items());
app.use(topLevelErrorHandler);

app.server.listen(process.env.PORT || 3000);
winston.info(`${process.env.SERVICE_NAME || 'demo-api'} started on port ${process.env.PORT || 3000}`);

export default app;

import { Router } from 'express';
import winston from 'winston';
import expressWinston from 'express-winston';
import helmet from 'helmet';
import bodyParser from 'body-parser';
import cors from 'cors';
import inflector from 'json-inflector';

export default () => {
  const router = Router();
  const inflectorOptions = {
    request: 'camelize',
    response: 'camelizeLower',
  };

  router.use(cors());
  router.use(helmet());
  router.use(bodyParser.json());
  router.use(inflector(inflectorOptions));

  winston.remove(winston.transports.Console);
  winston.add(winston.transports.Console, { timestamp: true, colorize: true });

  // Log all requests
  router.use(expressWinston.logger({
    transports: [
      new winston.transports.Console({
        timestamp: true,
        colorize: true,
      }),
    ],
    expressFormat: true,
  }));

  router.get('/favicon.ico', (req, res) => {
    res.destroy();
  });

  return router;
};

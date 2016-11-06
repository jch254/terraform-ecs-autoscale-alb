import { Router } from 'express';
import winston from 'winston';
import expressWinston from 'express-winston';
import helmet from 'helmet';
import bodyParser from 'body-parser';
import cors from 'cors';
import inflector from 'json-inflector';

export default () => {
  const api = Router();

  const inflectorOptions = {
    request: 'camelize',
    response: 'camelizeLower',
  };

  api.use(cors());
  api.use(helmet());
  api.use(bodyParser.json());
  api.use(inflector(inflectorOptions));

  winston.remove(winston.transports.Console);
  winston.add(winston.transports.Console, { timestamp: true, colorize: true });

  // Log all requests
  api.use(expressWinston.logger({
    transports: [
      new winston.transports.Console({
        timestamp: true,
        colorize: true,
      }),
    ],
    expressFormat: true,
  }));

  return api;
};

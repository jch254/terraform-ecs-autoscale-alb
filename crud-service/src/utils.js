import winston from 'winston';

const topLevelErrorHandler = (err, req, res) => {
  winston.error(`${err.message}`);

  if (!err.status) {
    winston.error(err.stack);
  }

  if (!res.headersSent) {
    res.status(err.status || 500).json({ message: err.responseMessage || 'Something broke' });
  }
};

const createErrorResponse = (message, statusCode) => {
  const err = new Error(message);

  err.responseMessage = message;
  err.status = statusCode;

  return err;
};

export { topLevelErrorHandler, createErrorResponse };

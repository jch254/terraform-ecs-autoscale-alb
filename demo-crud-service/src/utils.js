import winston from 'winston';

const urlRewriter = (req, res, next) => {
  const url = req.url.split('/');

  req.url = `/${url.slice(2).join('/')}`;

  next();
};

const notFoundHandler = (err, req, res) => {
  res.status(404).json({ message: 'Matrix glitch' });
};

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


export { urlRewriter, notFoundHandler, topLevelErrorHandler, createErrorResponse };

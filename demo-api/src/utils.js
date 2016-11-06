import winston from 'winston';

// Removes load balancer path from URL
const urlRewriter = (req, res, next) => {
  if (req.url.match(/\//g).length >= 2) {
    const urlParts = req.url.split('/').filter(p => p.length !== 0);

    req.url = `/${urlParts.slice(1).join('/')}`;
  }

  next();
};

const topLevelErrorHandler = (err, req, res, next) => {
  if (res.headersSent) {
    return next(err);
  }

  winston.error(`${err.message}`);

  if (!err.status) {
    winston.error(err.stack);
  }

  return res.status(err.status || 500).json({ message: err.responseMessage || 'Matrix glitch' });
};

const createErrorResponse = (message, statusCode) => {
  const err = new Error(message);

  err.responseMessage = message;
  err.status = statusCode;

  return err;
};


export { urlRewriter, topLevelErrorHandler, createErrorResponse };

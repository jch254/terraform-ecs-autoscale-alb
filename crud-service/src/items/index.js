import { Router } from 'express';

// TODO: CRUD items via DB
export default () => {
  const api = Router();

  api.get('/items', (req, res) => {
    res.json({ message: `Hello world from ${process.env.SERVICE_NAME}` });
  });

  return api;
};

import { Router } from 'express';

export default () => {
  const api = Router();

  api.get('/items', (req, res) => {
    res.json({ items: [] });
  });

  return api;
};

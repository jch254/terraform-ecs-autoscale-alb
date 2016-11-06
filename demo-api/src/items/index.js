import { Router } from 'express';

export default () => {
  const api = Router();

  api.get('/items', (req, res) => {
    res.json({ items: [{ id: 23, name: 'Cheers cobber' }] });
  });

  return api;
};

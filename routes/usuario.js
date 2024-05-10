import express from 'express';
import * as usuario from '../controllers/usuario.js';

const router = express.Router();

router.get('/usuario',usuario.consultar);
router.put('/usuario/:id',usuario.alterar);

export default router;

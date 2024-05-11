import express from 'express';
import * as usuario from '../controllers/usuario.js';

const router = express.Router();

router.get('/usuario',usuario.consultar);
router.get('/usuario/:id',usuario.consultarPorId);
router.put('/usuario/:id',usuario.alterar);
router.post('/usuario',usuario.cadastrar);

export default router;

import express from 'express';
import * as projeto from '../controllers/projeto.js'

const router = express.Router();

router.get('/projeto', projeto.consultar);
router.get('/projeto/:id', projeto.consultarPorId);
router.post('/projeto', projeto.cadastrar);
router.put('/projeto/:id', projeto.alterar);
// router.delete('/nutriente/:id', nutriente.deletar);
// router.post('/nutriente', nutriente.cadastrada);
// router.put('/nutriente/:id', nutriente.alterar);

export default router;
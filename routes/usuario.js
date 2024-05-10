import express from 'express';
import * as usuario from '../controllers/usuario.js';



const router = express.Router();

router.post('/login',usuario.login);

export default router;

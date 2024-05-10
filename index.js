import express from 'express';
import cors from 'cors'; 
import jwt from 'jsonwebtoken';
import bodyParser from 'body-parser';
import nutriente from './routes/nutriente.js';
import elemento from './routes/elemento.js';
import materia_prima from './routes/materia_prima.js';
import garantia from './routes/garantia.js';
import autenticacao from './routes/autenticacao.js';
import usuario from './routes/usuario.js';

const app = express();

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

app.get('/',(req,res)=>{
    res.status(200).json({ result: 'ok' });
});

// Rotas de autenticação
app.use('/', autenticacao);

// Middleware de autenticação JWT
app.use((req, res, next) => {
    const key_api = '%gtHy(86$kÇ.kb6i';
    const token = req.headers['autorizacao'];
    if (!token) {
        return res.status(401).json({ mensagem: 'Token de autenticação não fornecido' });
    }
    jwt.verify(token, key_api, (err, decoded) => {
        if (err) {
            return res.status(401).json({ mensagem: 'Token de autenticação inválido' });
        }
        req.usuario = decoded.usuario; // Armazena os dados do usuário decodificados na solicitação
        next();
    });
});

// Rotas protegidas pela autenticação

app.use('/', usuario);
app.use('/', elemento);
app.use('/', nutriente);
app.use('/', materia_prima);
app.use('/', garantia);

app.use((req, res, next) => {
    let retorno = {
        success: false,
        quant: 0,
        data: [],
        erro: 'Rota inválida'
    }
    res.status(500).json(retorno);
});

const PORT = 8080; 
app.listen(PORT,()=>{
    console.log('Sistema inicializado: ', `Acesso: http://localhost:${PORT}`);
});

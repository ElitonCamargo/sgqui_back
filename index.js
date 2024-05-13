import express from 'express';
import cors from 'cors'; 
import jwt from 'jsonwebtoken';
import bodyParser from 'body-parser';
import autenticacao from './routes/autenticacao.js';
import * as middleware from './routes/middleware.js';
import nutriente from './routes/nutriente.js';
import elemento from './routes/elemento.js';
import materia_prima from './routes/materia_prima.js';
import garantia from './routes/garantia.js';
import usuario from './routes/usuario.js';

const app = express();

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

// Rotas de públicas
app.get('/',(req,res)=>{
    const rootDomain = req.protocol + '://' + req.get('host');
    res.status(200).json({     
        status_server: 'ok',
        dominio_raiz : rootDomain,
        rotas:[
            `${rootDomain}/login`,
            `${rootDomain}/usuario`,
            `${rootDomain}/elemento`,
            `${rootDomain}/materia_prima`,
            `${rootDomain}/nutriente`,
            `${rootDomain}/carantia`,
        ]
    });
});

app.use('/', autenticacao); // Rotas de autenticação

// Middleware de autenticação JWT
app.use(middleware.middlewareAutenticação);

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

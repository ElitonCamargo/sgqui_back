import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import autenticacao from './routes/autenticacao.js';
import * as middleware from './controllers/middleware.js';
import nutriente from './routes/nutriente.js';
import elemento from './routes/elemento.js';
import materia_prima from './routes/materia_prima.js';
import garantia from './routes/garantia.js';
import usuario from './routes/usuario.js';
import projeto from './routes/projeto.js';
import etapa from './routes/etapa.js';
import etapa_mp from './routes/etapa_mp.js';
import configuracao from './routes/configuracao.js';
import upload from './controllers/upload.js';

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
            `${rootDomain}/usuario/login`,
            `${rootDomain}/usuario`,
            `${rootDomain}/elemento`,
            `${rootDomain}/materia_prima`,
            `${rootDomain}/nutriente`,
            `${rootDomain}/garantia`,
            `${rootDomain}/projeto`,
            `${rootDomain}/etepa`,
            `${rootDomain}/etepa_mp`,
            `${rootDomain}/configuracao`,
        ]
    });
});

app.use('/',upload);

// Rotas de autenticação
app.use('/', autenticacao);

// Middleware de autenticação JWT
app.use(middleware.middlewareAutenticacao);

// Rotas protegidas pelo middlewareAutenticacao
app.use('/', usuario);
app.use('/', elemento);
app.use('/', nutriente);
app.use('/', materia_prima);
app.use('/', garantia);
app.use('/', projeto);
app.use('/',etapa);
app.use('/',etapa_mp);
app.use('/',configuracao);

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

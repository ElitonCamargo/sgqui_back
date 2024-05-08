import express from 'express';
import cors from 'cors'; 
import bodyParser from 'body-parser';
import nutriente from './routes/nutriente.js';
import elemento from './routes/elemento.js';
import materia_prima from './routes/materia_prima.js';
import garantia from './routes/garantia.js';

const app = express();

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

app.get('/',(req,res)=>{
    res.status(200).json("{'result':'ok'}");
})


app.use('/', elemento);
app.use('/', nutriente);
app.use('/', materia_prima);
app.use('/', garantia);

app.use((req, res, next) => {
    res.status(404).json({ error: 'Rota não encontrada' });
});

const PORT = 8080; 
app.listen(PORT,()=>{
    console.log('Sistema inicializado: ', `Acesso: http://localhost:${PORT}`);
})
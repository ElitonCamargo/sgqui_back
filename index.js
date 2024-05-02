import express from 'express';
import cors from 'cors'; 
import bodyParser from 'body-parser';
import nutriente from './routes/nutriente.js'

const app = express();

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

app.get('/',(req,res)=>{
    res.status(200).json("{'result':'ok'}");
})

app.use('/', nutriente);


const PORT = 8080; 
app.listen(PORT,()=>{
    console.log('Sistema inicializado: ', `Acesso: http://localhost:${PORT}`);
})
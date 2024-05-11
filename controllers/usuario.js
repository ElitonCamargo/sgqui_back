import * as Usuario from '../models/Usuario.js';
import jwt from 'jsonwebtoken';
import * as View from '../view/index.js';


export const login =  async (req, res) => {
    const key_api = '%gtHy(86$kÇ.kb6i';
    const { email, senha } = req.body;
    try {  
        const result = await Usuario.login(email,senha);
        if(result){
            const token = jwt.sign({ usuario: result.email }, key_api, { expiresIn: '24h' });
            return res.json({ token });
        }
        return res.status(401).json({ mensagem: 'Credenciais inválidas' });
        
    } catch (error) {
        console.error(error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
}

export const consultarPorId = async (req, res)=>{
    try {
        const id = req.params.id;
        const data = await Usuario.consultarPorId(id);
        View.result(res,'GET',data);
    } catch (error) {
        View.erro(res, error);
    }
}

export const consultar = async (req, res)=>{
    try {
        const email = req.query.email;
        const nome = req.query.nome;
        let data = [];
        if(email){
            data = await Usuario.consultarPorEmail(email);
        }
        else if(nome){
            data = await Usuario.consultar(nome);
        }
        else{
            data = await Usuario.consultar();
        }
        View.result(res,'GET',data);
    } catch (error) {
        View.erro(res, error);
    }
}

export const cadastrar = async (req, res)=>{
    try {
        const usuario = req.body; 
        const novoUsuario = await Usuario.cadastrar(usuario);
        View.result(res, 'POST',novoUsuario);
    } catch (error) {
        View.erro(res,error);
    }
}

export const alterar = async (req, res)=>{
    try {
        let usuario = req.body;
        usuario.id = req.params.id;
        const usuarioAlterado = await Usuario.alterar(usuario);
        View.result(res, 'PUT',usuarioAlterado);
    } catch (error) {
        View.erro(res,error);
    }
}


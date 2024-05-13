import * as Usuario from '../models/Usuario.js';
import jwt from 'jsonwebtoken';
import * as View from '../view/index.js';


export const login =  async (req, res) => {
    const key_api = '%gtHy(86$kÇ.kb6i';
    const { email, senha } = req.body;
    try {  

        const usuario = await Usuario.login(email,senha);
        if(usuario){
            const expiracao = new Date();// Calcular a data de expiração
            expiracao.setDate(expiracao.getDate() + 1); // Adiciona 1 dia
            const token = jwt.sign({ usuario: usuario.id, exp: Math.floor(expiracao.getTime() / 1000) }, key_api);        
            let data = [
                {token: `Bearer ${token}`},
                {expiracao: expiracao},
                {usuario: usuario}
            ];
            return View.result(res,'GET',data);
        }
        else{
            return View.result(res,'GET',[],'Credenciais inválidas');       
        }
    } catch (error) {
        View.erro(res,{ mensagem: 'Erro interno do servidor', error: error });
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

export const consultarLogado = async (req, res)=>{
    try {
        const id = req.loginId;
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


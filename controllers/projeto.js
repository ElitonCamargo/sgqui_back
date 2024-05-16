import * as Projeto from '../models/Projeto.js';
import * as View from '../view/index.js';

export const consultar = async (req, res)=>{
    try {
        let nome = req.query.nome;
        nome = nome?nome:'';
        const data = await Projeto.consultar(nome);
        return View.result(res,'GET',data);
    } catch (error) {
        return View.erro(res, error);
    }
}

export const consultarPorId = async (req, res)=>{    
    try {
        let id = req.params.id;
        const data = await Projeto.consultarPorId(id);
        return View.result(res,'GET',data);
    } catch (error) {
        return View.erro(res, error);
    }
}

// export const deletar = async (req, res)=>{
//     try {
//         let id = req.params.id;
//         const data = await Nutriente.deletar(id);
//         View.result(res,'DELETE',data);
//     } catch (error) {
//         View.erro(res, error);
//     }
// }

export const cadastrar = async (req, res)=>{
    try {
        let projeto = req.body;
        projeto.loginId = req.loginId;
        const novoProjeto = await Projeto.cadastrar(projeto);
        return View.result(res, 'POST',novoProjeto);
    } catch (error) {
        return View.erro(res,error);
    }
}

export const alterar = async (req, res)=>{
    try {
        let projeto = req.body;
        projeto.id = req.params.id;
        const projetoAlterado = await Projeto.alterar(projeto,req.loginId);
        return View.result(res, 'PUT', projetoAlterado);
    } catch (error) {
        return View.erro(res,error);
    }
}


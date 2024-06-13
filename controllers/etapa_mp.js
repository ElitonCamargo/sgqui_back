import * as Etapa_MP from '../models/Etapa_MP.js';
import * as View from '../view/index.js';

export const cadastrar = async (req, res) => {
    try {
        const etapa_mp = req.body;
        
        const novoEtapa_MP = await Etapa_MP.cadastrar(etapa_mp);
        
        return View.result(res, 'POST', novoEtapa_MP);
    } catch (error) {
        return View.erro(res, error);
    }
}

export const alterar = async (req, res) => {
    try {
        let etapa_mp = req.body;
        
        etapa_mp.id = req.params.id;
        
        const etapa_mpAlterada = await Etapa_MP.alterar(etapa_mp);
        
        return View.result(res, 'PUT', etapa_mpAlterada);
    } catch (error) {
        return View.erro(res, error);
    }
}

export const consultarPorId = async (req, res) => {
    try {
        let id = req.params.id;
        
        const data = await Etapa_MP.consultarPorId(id);
        
        return View.result(res, 'GET', data);
    } catch (error) {
        return View.erro(res, error);
    }
}

export const consultarPorEtapa = async (req, res) => {
    try {
        let id_projeto = req.params.id;
        
        const data = await Etapa_MP.consultarPorEtapa(id_projeto);
        
        return View.result(res, 'GET', data);
    } catch (error) {
        return View.erro(res, error);
    }
}

export const deletar = async (req, res) => {
    try {
        let id = req.params.id;
        
        const data = await Etapa_MP.deletar(id);
        
        return View.result(res, 'DELETE', data);
    } catch (error) {
        return View.erro(res, error);
    }
}

// Define e exporta uma função assíncrona chamada 'alterarOrdem' para alterar a ordem das etapas de um projeto.
export const alterarOrdem = async (req, res) => {
    try {
        // Obtém um array com a nova ordem das etapas do projeto a partir do corpo da requisição.
        // Exemplo de dados recebidos: {"etapas":[{"id": 2, "ordem": 3}, {"id": 1, "ordem": 2}, {"id": 3, "ordem": 1}]}
        const ordemEtapa = req.body;

        // Chama a função 'alterarOrdem' do módulo 'Etapa' com os dados da nova ordem e aguarda a conclusão.
        const etapasReordenadas = await Etapa_MP.alterarOrdem(ordemEtapa);
        
        // Retorna a resposta com o resultado da operação usando a função 'result' do módulo 'View'.
        return View.result(res, 'PUT', etapasReordenadas,"Nenhuma alteração realizada");
    } catch (error) {
        // Em caso de erro, retorna a resposta de erro usando a função 'erro' do módulo 'View'.
        return View.erro(res, error);
    }
}


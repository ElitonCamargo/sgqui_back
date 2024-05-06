import * as Nutriente from '../models/Nutriente.js';
import * as View from '../view/index.js';

export const consultar = async (req, res)=>{
    let retorno = {
        success: false,
        data: null,
        erro: null
    }
    try {
        let nome = req.query.nome;
        nome = nome?nome:'';
        let result;
        result = await Nutriente.consultar(nome);
        if (result.length > 0) {
            retorno.success = true;
            retorno.data = result
            res.status(200).json(retorno);
        } else {
            res.status(404).json(retorno);
        }
    } catch (error) {
        console.error('Erro na consulta:', error);         
        retorno.erro = error;
        res.status(500).json(retorno);
    }
}

export const consultarPorId = async (req, res)=>{
    let retorno = {
        success: false,
        data: null,
        erro: null
    }
    try {
        let id = req.params.id;
        let result = await Nutriente.consultarPorId(id);
        if (result.length > 0) {
            retorno.success = true;
            retorno.data = result;
            res.status(200).json(retorno);
        } else {
            res.status(404).json(retorno);
        }
    } catch (error) {
        console.error('Erro ao consultar nutriente por ID:', error);
        retorno.erro = error;
        res.status(500).json(retorno);
    }
}

export const deletar = async (req, res)=>{
    try {
        let id = req.params.id;
        let result = await Nutriente.deletar(id);
        if (result.affectedRows > 0) {
            retorno.success = true;
            retorno.data = []
            res.status(204).json(retorno);
        } else {
            res.status(404).json({ erro: 'Recurso não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao deletar nutriente por ID:', error);
        retorno.erro = error;
        res.status(500).json(retorno);
    }
}

export const cadastrada = async (req, res)=>{
    try {
        const nutriente = req.body; 
        const novoNutriente = await Nutriente.cadastrar(nutriente);
        retorno.success = true;
        retorno.data = novoNutriente
        res.status(201).json(retorno);
    } catch (error) {
        console.error('Erro ao cadastrar Nutriente:', error);
        retorno.erro = error;
        res.status(500).json(retorno);
    }
}

export const alterar = async (req, res)=>{
    try {
        let nutriente = req.body;
        nutriente.id = req.params.id;
        const nutrienteAlterado = await Nutriente.alterar(nutriente);
        retorno.success = true;
        retorno.data = nutrienteAlterado
        res.status(201).json(retorno);
    } catch (error) {
        console.error('Erro ao cadastrar Nutriente:', error);
        retorno.erro = error;
        res.status(500).json(retorno);
    }
}


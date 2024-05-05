import * as Nutriente from '../models/Nutriente.js';

export const consultar = async (req, res)=>{
    try {
        let nome = req.query.nome;
        nome = nome?nome:'';
        let result;
        result = await Nutriente.consultar(nome);
        if (result.length > 0) {
            res.status(200).json(result);
        } else {
            res.status(404).json({ erro: 'Nenhum recurso encontrado' });
        }
    } catch (error) {
        console.error('Erro na consulta:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}

export const consultarPorId = async (req, res)=>{
    try {
        let id = req.params.id;
        let result = await Nutriente.consultarPorId(id);
        if (result.length > 0) {
            res.status(200).json(result);
        } else {
            res.status(404).json({ erro: 'Recurso não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao consultar nutriente por ID:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}

export const deletar = async (req, res)=>{
    try {
        let id = req.params.id;
        let result = await Nutriente.deletar(id);
        console.log(result);
        if (result.affectedRows > 0) {
            res.status(204).json([]);
        } else {
            res.status(404).json({ erro: 'Recurso não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao deletar nutriente por ID:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}

export const cadastrada = async (req, res)=>{
    try {
        const nutriente = req.body; 
        const novoNutriente = await Nutriente.cadastrar(nutriente);
        res.status(201).json(novoNutriente);
    } catch (error) {
        console.error('Erro ao cadastrar Nutriente:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}

export const alterar = async (req, res)=>{
    try {
        let nutriente = req.body;
        nutriente.id = req.params.id;
        const nutrienteAlterado = await Nutriente.alterar(nutriente);
        res.status(201).json(nutrienteAlterado);
    } catch (error) {
        console.error('Erro ao cadastrar Nutriente:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}


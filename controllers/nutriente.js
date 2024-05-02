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
        res.status(500).json({ erro: 'Erro interno do servidor' });
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
        res.status(500).json({ erro: 'Erro interno do servidor' });
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
        res.status(500).json({ erro: 'Erro interno do servidor' });
    }
}

export const cadastrada = async (req, res)=>{
    try {
        const { nome, formula } = req.body; 
        const novoNutriente = await Nutriente.cadastrar(nome, formula);
        res.status(201).json(novoNutriente);
    } catch (error) {
        console.error('Erro ao cadastrar Nutriente:', error);
        res.status(500).json({ erro: 'Erro interno do servidor' });
    }
}


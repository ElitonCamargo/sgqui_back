import * as Elemento from '../models/Elemento.js';

export const consultar = async (req, res)=>{
    try {
        let simbolo = req.query.simbolo;        
        let filtro = req.query.filtro;
        let result;
        
        if(simbolo)
            result = await Elemento.consultarPorSimbolo(simbolo);
        else if(filtro)
            result = await Elemento.consultar(filtro);
        else
            result = await Elemento.consultar();

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

export const consultarPorSimbolo = async (req, res)=>{
    try {
        let simbolo = req.query.simbolo;
        simbolo = simbolo?simbolo:'';
        let result;
        result = await Elemento.consultarPorSimbolo(simbolo);
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
        let result = await Elemento.consultarPorId(id);
        if (result.length > 0) {
            res.status(200).json(result);
        } else {
            res.status(404).json({ erro: 'Recurso não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao consultar elemento por ID:', error);
        res.status(500).json({ erro: 'Erro interno do servidor' });
    }
}

export const deletar = async (req, res)=>{
    try {
        let id = req.params.id;
        let result = await Elemento.deletar(id);
        if (result.affectedRows > 0) {
            res.status(204).json([]);
        } else {
            res.status(404).json({ erro: 'Recurso não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao deletar elemento por ID:', error);
        res.status(500).json({ erro: 'Erro interno do servidor' });
    }
}

export const cadastrada = async (req, res)=>{
    try {
        const elemento = req.body; 
        const novoelemento = await elemento.cadastrar(elemento);
        res.status(201).json(novoelemento);
    } catch (error) {
        console.error('Erro ao cadastrar elemento:', error);
        res.status(500).json({ erro: 'Erro interno do servidor' });
    }
}

export const alterar = async (req, res)=>{
    try { 
        const elemento = await Elemento.alterar(req.body);
        res.status(201).json(elemento);
    } catch (error) {
        console.error('Erro ao cadastrar elemento:', error);
        res.status(500).json({ erro: 'Erro interno do servidor' });
    }
}


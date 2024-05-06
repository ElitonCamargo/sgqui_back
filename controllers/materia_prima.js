import * as MateriaPrima from '../models/MateriaPrima.js';

export const consultar = async (req, res)=>{
    try {
        let result;
        const nome = req.query.nome;
        const formula = req.query.formula;
        const codigo = req.query.codigo;
        const cas_number = req.query.cas_number;
        if(nome){
            result = await MateriaPrima.consultar(nome);
        }
        else if(formula){
            result = await MateriaPrima.consultarPorFormula(formula);            
        }
        else if(codigo){
            result = await MateriaPrima.consultarPorCodigo(codigo);
        }
        else if(cas_number){
            result = await MateriaPrima.consultarPorCas_number(cas_number);
        }
        else{
            result = await MateriaPrima.consultar();
        }
        
        if (result.length > 0) {
            res.status(200).json(result);
        } else {
            res.status(404).json({ erro: 'Nenhum recurso encontrado' });
        }
    } catch (error) {
        console.error('Erro na consulta de Materia Prima:', error);
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
        let result = await MateriaPrima.consultarPorId(id);
        if (result.length > 0) {
            res.status(200).json(result);
        } else {
            res.status(404).json({ erro: 'Recurso não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao consultar Materia Prima por ID:', error);
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
        let result = await MateriaPrima.deletar(id);
        if (result.affectedRows > 0) {
            res.status(204).json([]);
        } else {
            res.status(404).json({ erro: 'Recurso não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao deletar Materia Prima por ID:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}

export const cadastrada = async (req, res)=>{
    try {
        const materia_prima = req.body; 
        const novoMateria_prima= await MateriaPrima.cadastrar(materia_prima);
        res.status(201).json(novoMateria_prima);
    } catch (error) {
        console.error('Erro ao cadastrar Materia Prima:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}

export const alterar = async (req, res)=>{
    try {
        let materia_prima = req.body;
        materia_prima.id = req.params.id;
        const materia_primaAlterado = await MateriaPrima.alterar(materia_prima);
        res.status(201).json(materia_primaAlterado);
    } catch (error) {
        console.error('Erro ao alterar Materia prima:', error);
        let erro = {
            erro: 'Erro interno do servidor',
            info_erro: error
        }
        res.status(500).json(erro);
    }
}


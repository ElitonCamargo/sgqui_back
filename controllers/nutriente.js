import * as Nutriente from '../models/Nutriente.js';

export const consultar = async (req, res)=>{
    try {
        let nome = req.query.nome;
        let result;
        if (nome) {
            result = await Nutriente.consultar(nome);
        } else {
            result = await Nutriente.consultar();
        }

        if (result.length > 0) {
            res.status(200).json(result);
        } else {
            // Se nenhum resultado for encontrado, retornar 404
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
        const { nome, formula } = req.body; // Os dados enviados tenham campos 'nome' e 'formula'

        // Chamar a função cadastrar com os dados recebidos
        const novoNutriente = await Nutriente.cadastrar(nome, formula);

        // Enviar uma resposta com os dados da novo Nutriente cadastrado
        res.status(201).json(novoNutriente);
    } catch (error) {
        // Lidar com erros, se houver algum
        console.error('Erro ao cadastrar Nutriente:', error);
        res.status(500).json({ erro: 'Erro interno do servidor' });
    }
}


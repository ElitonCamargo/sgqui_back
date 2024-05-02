import cx from '../database/data.js';

export const consultar = async (filtro = '') => {
    try {
        const cmdSql = 'SELECT * FROM nutriente WHERE nome LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`%${filtro}%`]);
        return dados;
    } catch (error) {
        console.error('Erro ao consultar nutriente:', error);
        throw error;
    }
};

export const consultarPorId = async (id) => {
    try {
        const cmdSql = 'SELECT * FROM nutriente WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        return dados;
    } catch (error) {
        console.error('Erro ao consultar nutriente por ID:', error);
        throw error;
    }
};

export const cadastrar = async (nome, formula) => {
    try {
        const cmdSql = 'INSERT INTO nutriente (nome, formula) VALUES (?, ?)';
        await cx.query(cmdSql, [nome, formula]);

        // Recuperar o último ID inserido
        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;

        // Consultar a empresa recém-cadastrada pelo último ID
        const [dados, meta_dados] = await cx.query('SELECT * FROM nutriente WHERE id = ?;', [lastId]);
        return dados;
    } catch (error) {
        console.error('Erro ao cadastrar nutriente:', error);
        throw error;
    }
};

export const deletar = async (id) => {
    try {
        const cmdSql = 'DELETE FROM nutriente WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        return dados;
    } catch (error) {
        console.error('Erro ao deletar nutriente:', error);
        throw error;
    }
};


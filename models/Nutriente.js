import pool from '../database/data.js';

export const consultar = async (filtro = '') => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM nutriente WHERE nome LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`%${filtro}%`]);
        cx.release();
        return dados;
    } catch (error) {
        console.error('Erro ao consultar nutriente:', error);
        throw error;
    }
};

export const consultarPorId = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM nutriente WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        console.error('Erro ao consultar nutriente por ID:', error);
        throw error;
    }
};

export const cadastrar = async (nome, formula) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'INSERT INTO nutriente (nome, formula) VALUES (?, ?)';
        await cx.query(cmdSql, [nome, formula]);

        // Recuperar o último ID inserido
        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;

        // Consultar a empresa recém-cadastrada pelo último ID
        const [dados, meta_dados] = await cx.query('SELECT * FROM nutriente WHERE id = ?;', [lastId]);
        cx.release();
        return dados;
    } catch (error) {
        console.error('Erro ao cadastrar nutriente:', error);
        throw error;
    }
};

export const alterar = async (id, novoNome, novaFormula) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'UPDATE nutriente SET nome = ?, formula = ? WHERE id = ?;';
        await cx.query(cmdSql, [novoNome, novaFormula, id]);
        const [dados, meta_dados] = await cx.query('SELECT * FROM nutriente WHERE id = ?;', [id]);
        cx.release();
        return dados;
    } catch (error) {
        console.error('Erro ao alterar nutriente:', error);
        throw error;
    }
};

export const deletar = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'DELETE FROM nutriente WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        console.error('Erro ao deletar nutriente:', error);
        throw error;
    }
};


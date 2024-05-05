import pool from '../database/data.js';

export const consultar = async (filtro = '') => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM nutriente WHERE nome LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`%${filtro}%`]);
        cx.release();
        return dados;
    } catch (error) {
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
        throw error;
    }
};

export const cadastrar = async (nutriente) => {
    try {
        const {nome, formula} = nutriente;
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
        throw error;
    }
};

export const alterar = async (nutriente) => {
    try {
        let valores = [];
        let cmdSql = 'UPDATE nutriente SET ';
        for(const key in nutriente){
            valores.push(nutriente[key]);
            cmdSql += `${key} = ?, `;
        }
        cmdSql = cmdSql.replace(', id = ?,', '');
        cmdSql += 'WHERE id = ?;';
        const cx = await pool.getConnection();
        await cx.query(cmdSql, valores);
        const [dados, meta_dados] = await cx.query('SELECT * FROM nutriente WHERE id = ?;', nutriente.id);
        cx.release();
        return dados;

    } catch (error) {
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
        throw error;
    }
};


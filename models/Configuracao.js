import pool from '../database/data.js';

export const cadastrar = async (configuracao) => {
    try {
        const { key, value } = configuracao;
        const cmdSql = 'INSERT INTO configuracao (`key`, `value`) VALUES (?,?);';
        
        const cx = await pool.getConnection();
        await cx.query(cmdSql, [key, JSON.stringify(value)]);

        const [dados] = await cx.query('SELECT * FROM configuracao WHERE `key` = ?;', [key]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const alterar = async (configuracao) => {
    try {
        const { key, value, id } = configuracao;
        const cmdSql = 'UPDATE configuracao SET `key`=?, `value`=? WHERE id = ?';

        const cx = await pool.getConnection();

        const [execucao] = await cx.query(cmdSql, [key, JSON.stringify(value),id]);

        if(execucao.affectedRows > 0){
            const [dados, meta_dados] = await cx.query('SELECT * FROM configuracao WHERE id = ?;', [id]);
            cx.release();
            return dados;
        }
        cx.release();
        return [];
    } catch (error) {
        throw error;
    }
};

export const consultar = async () => {
    try {
        const cx = await pool.getConnection();
        const [dados, meta_dados] = await cx.query('SELECT * FROM configuracao');
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorId = async (id) => {
    try {
        const cx = await pool.getConnection();
        const [dados, meta_dados] = await cx.query('SELECT * FROM configuracao WHERE id = ?;', [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorKey = async (key) => {
    try {
        const cx = await pool.getConnection();
        const [dados, meta_dados] = await cx.query('SELECT * FROM configuracao WHERE `key` = ?;', [key]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};


export const deletar = async (id) => {
    try {
        const cx = await pool.getConnection();
        const [dados, meta_dados] = await cx.query('DELETE FROM configuracao WHERE id = ?;', [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};
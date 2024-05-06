import pool from '../database/data.js';

export const consultar = async (filtro = '') => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM materia_prima WHERE nome LIKE ?;';
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
        const cmdSql = 'SELECT * FROM materia_prima WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorCodigo = async (codigo) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM materia_prima WHERE codigo LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [codigo]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorCas_number = async (cas_number) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM materia_prima WHERE cas_number LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [cas_number]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorFormula = async (formula) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM materia_prima WHERE formula LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`%${formula}%`]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const cadastrar = async (materia_prima) => {
    try {        
        let params_cmdSql = '';
        let values_cmdSql = '';
        let values = [];
        for(const key in materia_prima){
            values.push(materia_prima[key]);
            params_cmdSql += key+','
            values_cmdSql += '?,'
        }
        params_cmdSql = params_cmdSql.slice(0, -1);
        values_cmdSql = values_cmdSql.slice(0, -1);

        const cmdSql = 'INSERT INTO materia_prima ('+params_cmdSql+') VALUES ('+values_cmdSql+')';
        const cx = await pool.getConnection();
        await cx.query(cmdSql, values);

        // Recuperar o último ID inserido
        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;

        // Consultar a empresa recém-cadastrada pelo último ID
        const [dados, meta_dados] = await cx.query('SELECT * FROM materia_prima WHERE id = ?;', [lastId]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const alterar = async (materia_prima) => {
    try {
        let valores = [];
        let cmdSql = 'UPDATE materia_prima SET ';
        for(const key in materia_prima){
            valores.push(materia_prima[key]);
            cmdSql += `${key} = ?, `;
        }
        cmdSql = cmdSql.replace(', id = ?,', '');
        cmdSql += 'WHERE id = ?;';
        const cx = await pool.getConnection();     
        const [execucao] = await cx.query(cmdSql, valores);
        if(execucao.affectedRows > 0){
            const [dados, meta_dados] = await cx.query('SELECT * FROM materia_prima WHERE id = ?;', materia_prima.id);
            cx.release();
            return dados;
        }
        cx.release();
        return [];

    } catch (error) {
        throw error;
    }
};

export const deletar = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'DELETE FROM materia_prima WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};


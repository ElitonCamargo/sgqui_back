import pool from '../database/data.js';

export const consultarPorNutriente = async (nutrienteId) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = `SELECT 
            materia_prima.id as materia_prima_Id,
            materia_prima.nome as materia_prima_Nome,
            materia_prima.formula as materia_prima_Formula,
            materia_prima.densidade as materia_prima_Densidade,
            materia_prima.descricao as materia_prima_Descricao,
            materia_prima.cas_number as materia_prima_Cas_number,
            materia_prima.codigo as materia_prima_Codigo,
            garantia.id as garantia_Id,
            garantia.percentual as garantia_Percentual
        FROM 
            materia_prima
        JOIN
            garantia on materia_prima.id = garantia.materia_prima
        WHERE
            garantia.nutriente = ?;`;
        const [dados, meta_dados] = await cx.query(cmdSql, [nutrienteId]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorMateria_prima = async (materia_primaId) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = `SELECT
            nutriente.id as nutriente_Id,
            nutriente.nome as nutriente_Nome,
            nutriente.formula as nutriente_Formula,
            garantia.id as garantia_Id,
            garantia.percentual as garantia_Percentual
        FROM
            nutriente
            JOIN
            garantia ON nutriente.id = garantia.nutriente
        WHERE
            garantia.materia_prima = ?;`;
        const [dados, meta_dados] = await cx.query(cmdSql, [materia_primaId]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const cadastrar = async (garantia) => {
    try {
        const { materia_prima, nutriente, percentual } = garantia;
        const cmdSql = 'INSERT INTO garantia (materia_prima, nutriente, percentual) VALUES (?, ?, ?);';
        const cx = await pool.getConnection();
        await cx.query(cmdSql, [materia_prima, nutriente, percentual]);

        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;
 
        const [dados, meta_dados] = await cx.query('SELECT * FROM garantia WHERE id = ?;', [lastId]);
        cx.release();
        return dados;

    } catch (error) {
        throw error;
    }
};

export const atualizar = async (garantia) => {
    try {
        const { percentual, id } = garantia;
        const cmdSql = 'UPDATE garantia SET percentual = ? WHERE id = ?;';
        const cx = await pool.getConnection();
        const [execucao] = await cx.query(cmdSql, [percentual, id]);
        if(execucao.affectedRows > 0){
            const [dados, meta_dados] = await cx.query('SELECT * FROM garantia WHERE id = ?;', id);
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
        const cmdSql = 'DELETE FROM garantia WHERE id = ?;';
        const cx = await pool.getConnection();
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};
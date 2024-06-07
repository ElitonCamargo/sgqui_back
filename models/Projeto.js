import pool from '../database/data.js';

export const cadastrar = async (projeto={},loginId=0) => {
    try {

        let valores = [];
        let campos = '';
        let placeholders = '';        
        for(const key in projeto){
            campos += `${key},`;
            if(key != 'status'){                
                placeholders += '?,';
                valores.push(projeto[key]);
            }
            else{
                placeholders += `JSON_ARRAY(JSON_OBJECT('status',  '${projeto[key]}', 'data_alteracao', (SELECT CURRENT_TIMESTAMP), 'id_responsavel', '${loginId}')),`;
            }
        }
        campos = campos.slice(0, -1);
        placeholders = placeholders.slice(0, -1);
        const cmdSql = `INSERT INTO projeto (${campos}) VALUES (${placeholders});`;        
        const cx = await pool.getConnection();
        await cx.query(cmdSql, valores);

        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;

        const [dados, meta_dados] = await cx.query('SELECT * FROM projeto WHERE id = ?;', [lastId]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};



export const alterar = async (projeto={},loginId=0) => {
    try {
        let valores = [];
        let cmdSql = 'UPDATE projeto SET ';
        for(const key in projeto){
            if(key == 'status'){
                cmdSql += `status = JSON_MERGE_PRESERVE(JSON_ARRAY(JSON_OBJECT('status', '${projeto[key]}', 'data_alteracao', (SELECT CURRENT_TIMESTAMP), 'id_responsavel', '${loginId}')),status), `;
            }
            else{
                valores.push(projeto[key]);
                cmdSql += `${key} = ?, `;
            }
        }
        cmdSql = cmdSql.replace(', id = ?,', '');
        cmdSql += 'WHERE id = ?;';
        const cx = await pool.getConnection();     
        const [execucao] = await cx.query(cmdSql, valores);
        if(execucao.affectedRows > 0){
            const [dados, meta_dados] = await cx.query('SELECT * FROM projeto WHERE id = ?;', projeto.id);
            cx.release();
            return dados;
        }
        cx.release();
        return [];

    } catch (error) {
        throw error;
    }
};

export const consultar = async (filtro = '') => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM projeto WHERE nome LIKE ? or descricao LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`%${filtro}%`,`%${filtro}%`]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorId = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM projeto WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorData = async (data_inicio="", data_termino="") => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = `SELECT * FROM projeto
        WHERE (data_inicio BETWEEN '${data_inicio}' AND '${data_termino}')
           OR (data_termino BETWEEN '${data_inicio}' AND '${data_termino}')
           OR (data_inicio <= '${data_inicio}' AND data_termino >= '${data_termino}');
        `;
        const [dados, meta_dados] = await cx.query(cmdSql);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorStatus = async (status='') => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = `SELECT * FROM projeto WHERE JSON_UNQUOTE(JSON_EXTRACT(status, '$[0].status')) LIKE ?;`; 
        const [dados, meta_dados] = await cx.query(cmdSql,[status]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const deletar = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'DELETE FROM projeto WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};



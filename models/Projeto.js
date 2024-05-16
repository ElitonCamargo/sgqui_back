import pool from '../database/data.js';

export const cadastrar = async (projeto={}) => {
    try {
        const {nome, descricao, data_inicio, data_termino, status, loginId} = projeto;
       
        const cmdSql = `INSERT INTO projeto (nome, descricao, data_inicio, data_termino, status) VALUES (?, ?, ?, ?, JSON_ARRAY(JSON_OBJECT('id_status', ?, 'data_alteracao', (SELECT CURRENT_TIMESTAMP), 'id_responsavel', ?)));`;
        const cx = await pool.getConnection();
        await cx.query(cmdSql, [nome, descricao, data_inicio, data_termino, status, loginId]);

        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;

        const [dados, meta_dados] = await cx.query('SELECT id, nome, descricao, data_inicio, data_termino, status, getStatusAtual(id) as status_atual, createdAt, updatedAt FROM projeto WHERE id = ?;', [lastId]);
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
                cmdSql += `status = JSON_ARRAY_APPEND(status, '$', JSON_OBJECT('id_status', ${projeto[key]}, 'data_alteracao', (SELECT CURRENT_TIMESTAMP), 'id_responsavel', ${loginId})), `;
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
            const [dados, meta_dados] = await cx.query('SELECT id, nome, descricao, data_inicio, data_termino, status, getStatusAtual(id) as status_atual, createdAt, updatedAt FROM projeto WHERE id = ?;', projeto.id);
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
        const cmdSql = 'SELECT id, nome, descricao, data_inicio, data_termino, status, getStatusAtual(id) as status_atual, createdAt, updatedAt FROM projeto WHERE nome LIKE ? or descricao LIKE ?;';
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
        const cmdSql = 'SELECT id, nome, descricao, data_inicio, data_termino, status, getStatusAtual(id) as status_atual, createdAt, updatedAt FROM projeto WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorData = async (data_inicio, data_termino) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = `SELECT id, nome, descricao, data_inicio, data_termino, status, getStatusAtual(id) as status_atual, createdAt, updatedAt FROM projeto
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

export const consultarPorStatus = async (data_inicio, data_termino) => {
    //status
    try {
        const cx = await pool.getConnection();
        const cmdSql = `SELECT id, nome, descricao, data_inicio, data_termino, status, getStatusAtual(id) as status_atual, createdAt, updatedAt  FROM projeto
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



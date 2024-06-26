import pool from '../database/data.js';

export const consultar = async (filtro = '') => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM elemento WHERE nome LIKE ? or simbolo LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`%${filtro}%`,`%${filtro}%`]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};
export const consultarPorEstado = async (estado) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM elemento WHERE estado_padrao LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`${estado}`]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorId = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM elemento WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const consultarPorSimbolo = async (simbolo) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM elemento WHERE simbolo = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [simbolo]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const cadastrar = async (elemento) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'INSERT INTO elemento (simbolo, nome, numero_atomico, massa_atomica, grupo, periodo, ponto_de_fusao, ponto_de_ebulicao, densidade, estado_padrao, configuracao_eletronica, propriedades) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
        const { simbolo, nome, numero_atomico, massa_atomica, grupo, periodo, ponto_de_fusao, ponto_de_ebulicao, densidade, estado_padrao, configuracao_eletronica, propriedades } = elemento;
        await cx.query(cmdSql, [simbolo, nome, numero_atomico, massa_atomica, grupo, periodo, ponto_de_fusao, ponto_de_ebulicao, densidade, estado_padrao, configuracao_eletronica, propriedades]);
        
        // Recuperar o último ID inserido
        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;

        // Consultar o elemento recém-cadastrado pelo último ID
        const [dados, meta_dados] = await cx.query('SELECT * FROM elemento WHERE id = ?;', [lastId]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

export const alterar = async (elemento) => {
    try {
        let valores = [];
        let cmdSql = 'UPDATE elemento SET ';
        for(const key in elemento){
            valores.push(elemento[key]);
            cmdSql += `${key} = ?, `;
        }
        cmdSql = cmdSql.replace(', id = ?,', '');
        cmdSql += 'WHERE id = ?;'
        const cx = await pool.getConnection();
        const [execucao] = await cx.query(cmdSql, valores);
        if(execucao.affectedRows > 0){
            const [dados, meta_dados] = await cx.query('SELECT * FROM elemento WHERE id = ?;', elemento.id);
            cx.release();
            return dados;
        }
        cx.release();
        return [];
    } catch (error) {
        console.error('Erro ao alterar elemento:', error);
        throw error;
    }
};

export const deletar = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'DELETE FROM elemento WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    }
};

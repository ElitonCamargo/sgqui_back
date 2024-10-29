import pool from '../database/data.js';
import bcrypt from 'bcryptjs';

export const consultar = async (filtro = '') => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT id,nome,email,permissao,avatar,status,createdAt,updatedAt FROM usuario WHERE nome LIKE ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [`%${filtro}%`]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    } finally {
        if (cx) cx.release(); // Libere a conexão após o uso
    }
};

export const consultarPorId = async (id) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT id,nome,email,permissao,avatar,status,createdAt,updatedAt FROM usuario WHERE id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    } finally {
        if (cx) cx.release(); // Libere a conexão após o uso
    }
};

export const consultarPorEmail = async (email) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT id,nome,email,permissao,avatar,status,createdAt,updatedAt FROM usuario WHERE email = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [email]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    } finally {
        if (cx) cx.release(); // Libere a conexão após o uso
    }
};

export const login = async (email, senha)=>{
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM usuario WHERE email = ?;';
        const [result, meta_dados] = await cx.query(cmdSql, [email]);
        cx.release();               
        if(result[0]){
            let usuario = result[0];
            const senhaValida = await bcrypt.compare(senha, usuario.senha);
            if(senhaValida){
                usuario.senha = "";
                return usuario
            }
        }
        return false;
    } catch (error) {
        throw error;     
    }
}

export const cadastrar = async (usuario) => {
    try {        
        const {nome,email,senha,permissao,avatar,status} = usuario;
        const cmdSql = 'INSERT INTO usuario (nome,email,senha,permissao,avatar,status) VALUES (?, ?, ?, ?, ?, ?);';
        const cx = await pool.getConnection();
        const hashSenha = await bcrypt.hash(senha, 10);
        await cx.query(cmdSql, [nome,email,hashSenha,permissao,avatar,status]);

        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;
 
        const [dados, meta_dados] = await cx.query('SELECT id,nome,email,permissao,avatar,status,createdAt,updatedAt FROM usuario WHERE id = ?;', [lastId]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    } finally {
        if (cx) cx.release(); // Libere a conexão após o uso
    }
};

export const alterar = async (usuario) => {
    try {
        let valores = [];
        let cmdSql = 'UPDATE usuario SET ';
        for(const key in usuario){
            if(key === 'senha'){
                const hashSenha = await bcrypt.hash(usuario[key], 10);
                valores.push(hashSenha);
            }
            else{
                valores.push(usuario[key]);
            }
            cmdSql += `${key} = ?, `;
        }
        cmdSql = cmdSql.replace(', id = ?,', '');
        cmdSql += 'WHERE id = ?;';
        const cx = await pool.getConnection();     
        const [execucao] = await cx.query(cmdSql, valores);
        if(execucao.affectedRows > 0){
            const [dados, meta_dados] = await cx.query('SELECT * FROM usuario WHERE id = ?;', usuario.id);
            cx.release();
            return dados;
        }
        cx.release();
        return [];

    } catch (error) {
        throw error;
    } finally {
        if (cx) cx.release(); // Libere a conexão após o uso
    }
};

export const deletar = async (id) => {
    try {
        const cmdSql = 'DELETE FROM usuario WHERE id = ?;';
        const cx = await pool.getConnection();
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();
        return dados;
    } catch (error) {
        throw error;
    } finally {
        if (cx) cx.release(); // Libere a conexão após o uso
    }
};
import pool from '../database/data.js';
import bcrypt from 'bcryptjs';

export const consultar = async (token) => {
    try {
        const cx = await pool.getConnection();
        const cmdSql = 'CALL token_consultar(?)';
        const [dados, meta_dados] = await cx.query(cmdSql, token);
        cx.release();
        return dados[0][0];
    } catch (error) {
        throw error;
    }
};

export const criar = async (usuario,validade,chave_token=new Date()) => { 
    try {        
        const hashToken = await bcrypt.hash(chave_token.toString(), 1);
        
        const cmdSql = 'CALL token_criar(?,?,?);';
        const cx = await pool.getConnection();        
        const [dados, meta_dados] = await cx.query(cmdSql, [usuario,validade,hashToken]);
        cx.release();
        if(dados[0][0]){
            return dados[0][0];
        }
        return false;
    } catch (error) {
        throw error;
    }
};

export const extender = async (usuario,tempo_horas) => { 
    try {        
        const cmdSql = 'CALL token_extender(?,?);';
        const cx = await pool.getConnection();        
        const [dados, meta_dados] = await cx.query(cmdSql, [usuario,tempo_horas]);
        cx.release();
        return dados.affectedRows > 0;
    } catch (error) {
        throw error;
    }
};

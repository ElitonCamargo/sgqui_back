import pool from '../database/data.js';
import bcrypt from 'bcryptjs';


export const login = async (email, senha)=>{
    // const usuario = await Usuario.findOne({ email });

    // if (!usuario) {
    //     return res.status(401).json({ mensagem: 'Credenciais inválidas' });
    // }

    // const senhaValida = await bcrypt.compare(senha, usuario.senha);

    // if (!senhaValida) {
    //     return res.status(401).json({ mensagem: 'Credenciais inválidas' });
    // }
    if(email === 'admin@com' && senha === 'admin123'){
        return {
            email: email,
            senha: senha
        };       
    }
    return false;
}

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
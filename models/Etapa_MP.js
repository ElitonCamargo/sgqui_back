import pool from '../database/data.js';

export const cadastrar = async (etapa_mp={}) => {
    try {
        let values = [];       
        let columns = '';      
        let placeholders = ''; 

        for(const key in etapa_mp){
            columns += `${key},`;       
            placeholders += '?, ';      
            values.push(etapa_mp[key]); 
        }

        columns = columns.slice(0, -1);
        placeholders = placeholders.slice(0, -2);

        const cmdSql = `INSERT INTO etapa_mp (${columns}) VALUES (${placeholders});`;
                
        const cx = await pool.getConnection();

        await cx.query(cmdSql, values);

        const [result] = await cx.query('SELECT LAST_INSERT_ID() as lastId');
        const lastId = result[0].lastId;

        const [dados] = await cx.query('SELECT * FROM etapa_mp WHERE id = ?;', [lastId]);

        cx.release();

        return dados;
    } catch (error) {
        throw error;
    }
};


export const alterar = async (etapa_mp={}) => {
    try {
        let values = [];               
        let columns_placeholders = ''; 

        for(const key in etapa_mp){
            columns_placeholders += `${key}=?,`;
            values.push(etapa_mp[key]);         
        }
        values.push(etapa_mp.id);  

        columns_placeholders = columns_placeholders.slice(0, -1);

        const cmdSql = `UPDATE etapa_mp SET ${columns_placeholders} WHERE id = ?`;

        const cx = await pool.getConnection();

        const [execucao] = await cx.query(cmdSql, values);

        if(execucao.affectedRows > 0){
            const [dados] = await cx.query('SELECT * FROM etapa_mp WHERE id = ?;', [etapa_mp.id]);
            cx.release();
            return dados;
        }
        cx.release();
        return [];

    } catch (error) {
        throw error;
    }
};

export const consultarPorEtapa = async (id_etapa) => {
    try {
        const cx = await pool.getConnection();        
        const cmdSql = 'SELECT * FROM etapa_mp WHERE etapa_mp.etapa = ? ORDER BY etapa_mp.ordem ASC;';        
        const [dados] = await cx.query(cmdSql, [id_etapa]);        
        cx.release();        
        return dados;
    } catch (error) {
        throw error;
    }
};


export const consultarPorId = async (id) => {
    try {
        const cx = await pool.getConnection();
        
        const cmdSql = 'SELECT * FROM etapa_mp WHERE id = ?;';
        
        const [dados] = await cx.query(cmdSql, [id]);
        
        cx.release();
        
        return dados;
    } catch (error) {
        throw error;
    }
};


export const deletar = async (id) => {
    try {
        const cx = await pool.getConnection();
        try {
            await cx.beginTransaction();
            let cmdSql = 'SELECT etapa, ordem FROM etapa_mp WHERE id = ?;';

            let [result] = await cx.query(cmdSql, [id]);
            console.log(result[0])

            let execucaoDelete ={
                affectedRows:0
            };

            if(result[0]){
                const etapa = result[0].etapa;
                const ordem = result[0].ordem;

                cmdSql = 'DELETE FROM etapa_mp WHERE id = ?;';
                [execucaoDelete] = await cx.query(cmdSql, [id]);

                if (execucaoDelete.affectedRows > 0) {
                    const cmdSql = `UPDATE etapa_mp SET ordem=ordem-1 WHERE etapa = ? AND ordem > ?`;
                    await cx.query(cmdSql, [etapa, ordem]);
                    console.log(etapa,ordem);
                }

            }
           
            console.log(execucaoDelete);
            await cx.commit();

            cx.release();

            return execucaoDelete;

        } catch (err) {
            await cx.rollback();
            cx.release();
            throw err;
        }
    } catch (error) {
        throw error;
    }
};


export const alterarOrdem = async (ordemetapa_mp = []) => {
    try {
        
        // Converte a lista de etapas para JSON
        
        let ordemetapa_mpJson = ordemetapa_mp;
        if (typeof ordemetapa_mpJson !== 'string') 
        {
            ordemetapa_mpJson = JSON.stringify(ordemetapa_mpJson);
        }
        
        const cx = await pool.getConnection();

        try {
            const cmdSql = `CALL etapa_mp_alterarOrdemMateriasPrimas(?)`;
            await cx.query(cmdSql, [ordemetapa_mpJson]);

            cx.release();

            return ordemetapa_mp;
        } catch (err) {
            cx.release();
            throw err;
        }
    } catch (error) {
        throw error;
    }
};

/* Funções feitas
    consultarPorId,
    consultarPorEtapa => consulta as matérias primas que uma etapa possúi
    cadastrar,
    alterar,
    delete

*/

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
    // Exemplo de ordemetapa_mp:
    [
        {
            "etapa_id": 2,
            "nutriente_ordem": [
                {
                    "nutriente_id": 4,
                    "ordem": 1
                }
            ]
        },
        {
            "etapa_id": 1,
            "nutriente_ordem": [
                {
                    "nutriente_id": 3,
                    "ordem": 1
                },
                {
                    "nutriente_id": 2,
                    "ordem": 2
                },
                {
                    "nutriente_id": 6,
                    "ordem": 3
                }
            ]
        },
        {
            "etapa_id": 3,
            "nutriente_ordem": [
                {
                    "nutriente_id": 1,
                    "ordem": 1
                },
                {
                    "nutriente_id": 5,
                    "ordem": 2
                }
            ]
        }
    ]


    
    try {
        // Obtém uma conexão do pool de conexões.
        const cx = await pool.getConnection();

        try {
            // Inicia a transação.
            await cx.beginTransaction();

            // Variável para contar o número de linhas afetadas.
            let totalAffectedRows = 0;

            // Itera sobre cada etapa_mp para construir e executar a consulta SQL de atualização.
            for (const etapa_mp of ordemetapa_mp) {
                const cmdSql = `UPDATE etapa_mp SET ordem = ? WHERE id = ?`;
                const [result] = await cx.query(cmdSql, [etapa_mp.ordem, etapa_mp.id]);
                totalAffectedRows += result.affectedRows;
            }

            // Confirma a transação.
            await cx.commit();

            // Libera a conexão de volta para o pool.
            cx.release();
            console.log(totalAffectedRows);

            if(totalAffectedRows > 0){
                return  ordemetapa_mp;
            }
            return [];
        } catch (err) {
            // Em caso de erro, desfaz todas as alterações da transação.
            await cx.rollback();
            // Libera a conexão de volta para o pool.
            cx.release();
            // Lança o erro para ser tratado pelo bloco externo.
            throw err;
        }
    } catch (error) {
        // Lança qualquer erro que ocorra durante a execução das operações.
        throw error;
    }
};

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

// *************** Consultas Entre vária entidades ***********************

export const consultaDetalhada = async (id) => {
    let id_unicas_etapas = [];
    let id_unicas_etapas_mp = [];
    let percentual_concluido = 0;
    let dencidade_estimada = 0;

    const etapaEhUnica = (id_etapa)=>{
        if(!id_unicas_etapas.includes(id_etapa)){
            id_unicas_etapas.push(id_etapa);
            return true;
        }
        return false;
    }

    const etapa_mpEhUnica = (id_etapa_mp)=>{
        if(!id_unicas_etapas_mp.includes(id_etapa_mp)){
            id_unicas_etapas_mp.push(id_etapa_mp);
            return true;
        }
        return false;
    }

    let nutrientes = [];
    const addNutrientes = (id,nome,formula,percentual_origem,mp,)=>{
        let nutriente = nutrientes.find(nutriente => nutriente.id == id);
        if(!nutriente){            
            nutrientes.push({
                "index": nutrientes.length-1,
                "id": id,
                "nome": nome,
                "formula": formula,
                "percentual": percentual_origem,
                "origem":[{
                    "mp":mp,
                    "percentual":percentual_origem
                }]
            });
        }
        else{
            let i = nutriente.index;            
            nutrientes[i].percentual += percentual_origem;
            nutrientes[i].origem.push({
                "mp":mp,
                "percentual":percentual_origem
            });
        }
        return false;
    }
    

    try {
        const cx = await pool.getConnection();
        const cmdSql = 'SELECT * FROM projeto_detalhado WHERE projeto_id = ?;';
        const [dados, meta_dados] = await cx.query(cmdSql, [id]);
        cx.release();

        let etapas = [];
        for(const elemento of dados){  
            if(etapaEhUnica(elemento.etapa_id)){
                etapas.push({
                    "id": elemento.etapa_id,
                    "nome": elemento.etapa_nome,
                    "descricao": elemento.etapa_descricao,
                    "ordem": elemento.etapa_ordem,
                    "etapa_mp":[

                    ]
                });
            }
            if(etapa_mpEhUnica(elemento.etapa_mp_id)){
                etapas[(etapas.length)-1].etapa_mp.push({
                    "id": elemento.etapa_mp_id,
                    "materia_prima": elemento.materia_prima_nome,
                    "percentual": elemento.etapa_mp_percentual,
                    "tempo_agitacao": elemento.etapa_mp_tempo_agitacao,
                    "observacao": elemento.etapa_mp_observacao,
                    "ordem": elemento.etapa_mp_ordem
                });
                percentual_concluido += elemento.etapa_mp_percentual;
                dencidade_estimada +=elemento.parcial_densidade?elemento.parcial_densidade:0;
            }
            addNutrientes(elemento.nutriente_id,elemento.nutriente_nome, elemento.nutriente_formula, elemento.percentual_origem,elemento.materia_prima_nome)
            
        }

        let projeto = {
            "id":             dados[0].projeto_id,
            "nome":           dados[0].projeto_nome,
            "descricao":      dados[0].projeto_descricao,
            "data_inicio":    dados[0].projeto_data_inicio,
            "data_termino":   dados[0].projeto_data_termino,
            "densidade":      dados[0].projeto_densidade,
            "ph":             dados[0].projeto_ph,
            "tipo":           dados[0].projeto_tipo,
            "aplicacao":      dados[0].projeto_aplicacao,
            "natureza_fisica":dados[0].projeto_natureza_fisica,
            "status":         dados[0].projeto_status,
            "etapas":etapas,
            "nutrientes":nutrientes,
            "percentual_concluido": percentual_concluido,
            "percentual_restante": 100 - percentual_concluido,
            "dencidade_estimada": dencidade_estimada
        }

        return [projeto];
    } catch (error) {
        throw error;
    }
};
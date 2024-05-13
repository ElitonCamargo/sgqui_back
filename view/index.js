const result = (res, method, data,info_erro=false)=>{
    let retorno = {
        success: false,
        quant: 0,
        data: [],
        erro: ''
    }
    if(method==='GET'){
        if (data.length > 0) {
            retorno.quant = data.length;
            retorno.success = true;
            retorno.data = data
            return res.status(200).json(retorno);
        } else {
            if(info_erro){
                retorno.erro = info_erro
            }
            return res.status(404).json(retorno);
        }
    }
    else if(method==='POST'){       
        retorno.quant = data.length;
        retorno.success = true;
        retorno.data = data
        return res.status(201).json(retorno);        
    }
    else if(method==='PUT'){
        if(data.length > 0){
            retorno.quant = data.length;
            retorno.success = true;
            retorno.data = data
            return res.status(201).json(retorno);
        }
        else{
            retorno.erro = "Recurso não encontrado";
            return res.status(404).json(retorno);
        }
    }
    else if(method==='DELETE'){
        if (data.affectedRows > 0) {
            retorno.quant = data.affectedRows;
            retorno.success = true;
            retorno.data = []
            return res.status(201).json(retorno);
        } else {
            retorno.erro = "Recurso não encontrado";
            return res.status(404).json(retorno);
        }
    }
    else{
        erro(res, 'Método http não identificado');
    }
}
const erro = (res, erro)=>{
    console.error(erro);
    let retorno = {
        success: false,
        quant: 0,
        data: [],
        erro: erro
    }
    return res.status(500).json(retorno);
}

export {result, erro};
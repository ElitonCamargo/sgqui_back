const result = (res, method, data)=>{
    if(method==='POST'){
        
    }
}
const erro = (res, erro)=>{
    console.error(erro);
    let retorno = {
        success: false,
        data: null,
        erro: erro
    }
    res.status(500).json(retorno);
}

export {result, erro};
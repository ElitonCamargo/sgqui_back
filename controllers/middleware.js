import jwt from 'jsonwebtoken';

export const middlewareAutenticacao = (req, res, next) => {
    try {
        const key_api = '%gtHy(86$kÇ.kb6i';
        const authorizationHeader = req.headers['authorization'];

        if (!authorizationHeader) {
            const retorno = {
                success: false,
                quant: 0,
                data: [],
                status:498,
                erro: 'Token de autenticação não fornecido'
            };
            return res.status(498).json(retorno);
        }

        const [bearer, token] = authorizationHeader.split(' ');

        if (bearer !== 'Bearer' || !token) {
            const retorno = {
                success: false,
                quant: 0,
                data: [],
                status:498,
                erro: 'Formato de token inválido'
            };
            return res.status(498).json(retorno);
        }

        jwt.verify(token, key_api, (err, decoded) => {
            if (err) {
                let retorno = {
                    success: false,
                    quant: 0,
                    data: [],
                    status:498,
                    erro: 'Token de autenticação inválido'
                }
                return res.status(498).json(retorno);
            }
            req.loginId = decoded.usuario; // Armazena os dados do usuário decodificados na solicitação            
            next();
        });
               
    } catch (error) {
        console.error(error);
        let retorno = {
            success: false,
            quant: 0,
            data: [],
            status:500,
            erro: 'Erro interno do servidor: '+ error
        }
        return res.status(500).json(retorno);
    }
};


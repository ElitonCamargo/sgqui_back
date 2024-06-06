// ****************** Configuração do banco de dados ************************** //
const developmentConfig = {
    host: "100.26.59.163",
    port: 3306,
    name: "api_sg_qui",
    dialect: "mysql",
    user: "admin_api",
    password: "%gt&j7&gfE0u1895"
};

const productionConfig = {
    host: process.env.DB_HOST || '108.167.151.37',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    name: process.env.BD_NAME || 'drawbe66_sgqui',
    dialect: process.env.BD_DIALECT || 'mysql',
    user: process.env.BD_USER || 'drawbe66_sgqui',
    password: process.env.BD_PASS || 'Sg_Qui123'
};

export const db = process.env.NODE_ENV === 'production' ? productionConfig : developmentConfig;

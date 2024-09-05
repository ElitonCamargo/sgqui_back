// ****************** Configuração do banco de dados ************************** //
const developmentConfig = {
    host: "100.26.59.163",
    port: 3306,
    name: "api_sg_qui_dev",
    dialect: "mysql",
    user: "admin_api",
    password: "%gt&j7&gfE0u1895"
};

const productionConfig = {
    host: process.env.DB_HOST || '100.26.59.163',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    name: process.env.BD_NAME || 'api_sg_qui_dev',
    dialect: process.env.BD_DIALECT || 'mysql',
    user: process.env.BD_USER || 'admin_api',
    password: process.env.BD_PASS || '%gt&j7&gfE0u1895'
};

export const db = process.env.NODE_ENV === 'production' ? productionConfig : developmentConfig;

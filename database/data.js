import mysql from 'mysql2/promise';
import { db } from "../config/config.js";

const pool = mysql.createPool({
    host: db.host,
    user: db.user,
    database: db.name,
    password: db.password,
    waitForConnections: true,
    connectionLimit: 10, // ajuste o limite conforme necessário
    queueLimit: 0
});

export default pool;
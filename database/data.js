import mysql from 'mysql2/promise';
import { db } from "../config/config.js";

const cx = await mysql.createConnection({
    host: db.host,
    user: db.user,
    database: db.name,
    password: db.password
});

export default cx;
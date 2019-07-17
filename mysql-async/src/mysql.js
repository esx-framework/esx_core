const mysql = require('mysql');

let config = {};
let debug = 0;
let pool;

function prepareQuery(query, parameters) {
    let sql = query;
    if (parameters !== null && typeof parameters === 'object') {
        sql = query.replace(/@(\w+)/g, (txt, key) => {
            if (parameters.hasOwnProperty(key)) {
                return mysql.escape(parameters[key]);
            } else if (parameters.hasOwnProperty(`@${key}`)) {
                return mysql.escape(parameters[`@${key}`]);
            }
            return txt;
        });
    }
    return sql;
}

function writeDebug(time, sql, error) {
    if (error) console.log(`[ERROR] [MySQL] An error happens on MySQL for query "${sql}": ${error.message}`)
    if (debug) console.log(`[MySQL] [${(time[0]*1e3+time[1]*1e-6).toFixed()}ms] ${sql}`);
}

async function safeInvoke(callback, args) {
    if (typeof callback === 'function') setImmediate(() => {
        callback(args);
    });
}

// transform tinyint(1) to boolean
function useBoolean(fields, results) {
    if (fields) {
        fields.forEach(field => {
            // found a column with tinyint(1)
            if (field.type === 1 && field.length === 1) {
                results.forEach((_, index) => {
                    results[index][field.name] = (results[index][field.name] !== 0);
                });
            }
        });
    }
    return results;
}

global.exports('mysql_execute', (query, parameters, callback) => {
    let sql = prepareQuery(query, parameters);
    let start = process.hrtime();
    pool.query(sql, (error, results) => {
        writeDebug(process.hrtime(start), sql, error);
        safeInvoke(callback, (results) ? results.affectedRows : 0);
    });
});

global.exports('mysql_fetch_all', (query, parameters, callback) => {
    let sql = prepareQuery(query, parameters);
    let start = process.hrtime();
    pool.query(sql, (error, results, fields) => {
        writeDebug(process.hrtime(start), sql, error);
        results = useBoolean(fields, results);
        safeInvoke(callback, results);
    });
});

global.exports('mysql_fetch_scalar', (query, parameters, callback) => {
    let sql = prepareQuery(query, parameters);
    let start = process.hrtime();
    pool.query(sql, (error, results, fields) => {
        writeDebug(process.hrtime(start), sql, error);
        results = useBoolean(fields, results);
        safeInvoke(callback, (results) ? Object.values(results[0])[0] : null);
    });
});

global.exports('mysql_insert', (query, parameters, callback) => {
    let sql = prepareQuery(query, parameters);
    let start = process.hrtime();
    pool.query(sql, (error, results) => {
        writeDebug(process.hrtime(start), sql, error);
        safeInvoke(callback, (results) ? results.insertId : 0);
    });
});

function parseOptions(config, options) {
    const cfg = config;
    const opts = options.split('&');
    opts.forEach((o) => {
        const keyValue = o.split('=');
        cfg[keyValue[0]] = keyValue[1];
    });
    return cfg;
}

function parseConnectingString(connectionString) {
    if(/(?:database|initial\scatalog)=(?:(.*?);|(.*))/gi.test(connectionString)) {

        let matches = (/(?:host|server|data\s?source|addr(?:ess)?)=(?:(.*?);|(.*))/gi.exec(connectionString));
        const host = (matches) ? matches[1] || matches[2] : 'localhost';
        matches = (/(?:Port)=(?:(.*?);|(.*))/gi.exec(connectionString));
        const port = (matches) ? matches[1] || matches[2] : 3306;
        matches = (/(?:user\s?(?:id|name)?|uid)=(?:(.*?);|(.*))/gi.exec(connectionString));
        const user = (matches) ? matches[1] || matches[2] : 'root';
        matches = (/(?:password|pwd)=(?:(.*?);|(.*))/gi.exec(connectionString));
        const password = (matches) ? matches[1] || matches[2] : '';
        matches = (/(?:database|initial\scatalog)=(?:(.*?);|(.*))/gi.exec(connectionString));
        const database = (matches) ? matches[1] || matches[2] : '';
        return { host, port, user, password, database, dateStrings: true };

    } else if(/mysql:\/\//gi.test(connectionString)) {

        let matches = /mysql:\/\/(.*?)(?::|@)(?:(.*)@)?(.*?)(?::(\d{1,5}))?\/(.*?)\?(.*)/gi.exec(connectionString);
        const host = (matches[3]) ? matches[3] : 'localhost';
        const port = (matches[4]) ? matches[4] : 3306;
        const user = (matches[1]) ? matches[1] : 'root';
        const password = (matches[2]) ? matches[2] : '';
        const database = (matches[5]) ? matches[5] : '';
        const config = { host, port, user, password, database };
        const options = matches[6];
        return parseOptions(config, options);

    } else throw new Error('No valid connection string found');
}

let isReady = false;
global.on('onServerResourceStart', (resourcename) => {
    if (resourcename == 'mysql-async') {
        const connectionString = global.GetConvar('mysql_connection_string', 'mysql://localhost/');
        config = parseConnectingString(connectionString);
        debug = global.GetConvarInt('mysql_debug', 0);
        pool = mysql.createPool(config);
        global.emit('onMySQLReady'); // avoid ESX bugs
        isReady = true;
    }
    if (isReady) {
        global.emit('MySQLReady'); // avoid ESX bugs
    }
});

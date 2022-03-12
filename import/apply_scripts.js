const {Pool} = require('pg')
const common = require('./common');

require('dotenv').config();

(async function () {
    const pool = new Pool();
    pool.on("connect", client => {
        client.on("notice", notice => console.log(notice.message));
    });
    await common.apply_scripts(process.argv[2], pool);
    await pool.end();
})().catch(error => {
    console.error(error)
});
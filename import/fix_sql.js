const fs = require('fs').promises;
const {Pool} = require('pg')
const common = require('./common');

require('dotenv').config();

(async function () {
    const pool = new Pool();

    let directory = 'sql';
    await common.listFiles(directory, /^.*\.sql$/).then(async files => {
        for (const file of files) {
            console.log('applying ' + file);
            let filePath = directory + "/" + file;
            let request = await fs.readFile(filePath)
                .then(data => data.toString());
            await pool.query(request);
        }
    })

    await pool.end();
})().catch(error => {
    console.error(error)
});
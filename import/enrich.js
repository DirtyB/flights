const fs = require('fs').promises;
const {Pool} = require('pg')
const common = require('./common');

require('dotenv').config()

const updateRequest = "UPDATE raw_airport SET timezone = $1 WHERE code = $2;";

async function process_file(directory, file, pool) {
    let filePath = directory + "/" + file;
    console.log("improting data from " + file);
    let data = await fs.readFile(filePath)
        .then(data => data.toString());
    let parsedData = JSON.parse(data);

    let code = file.match(common.tz_filePattern)[1];

    let params = [
        parsedData.TimeZoneId,
        code
    ];

    return pool.query(updateRequest ,params);
}

(async function () {
    const pool = new Pool();

    await common.listFiles(common.tz_path, common.tz_filePattern).then(files => {
        return Promise.all(files.map(file => process_file(common.tz_path, file, pool)))
    })

    await pool.end();
})().catch(error => {
    console.error(error)
});
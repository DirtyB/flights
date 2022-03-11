const fs = require('fs').promises;
const {Pool} = require('pg')
const common = require('./common');

require('dotenv').config()

const clearAllRequest = "TRUNCATE raw_ariport;"
const insertRequest = "INSERT INTO raw_ariport (code, name, country, lat, lon) VALUES ($1, $2, $3, $4, $5);";

async function process_file(directory, file, pool) {
    let filePath = directory + "/" + file;
    console.log("improting data from " + file);
    let data = await fs.readFile(filePath)
        .then(data => data.toString());
    let parsedData = JSON.parse(data);
    return Promise.all(parsedData.data.map(record => {
        let params = [
            record.id,
            record.name,
            record.country,
            record.lat,
            record.lon
        ];
        return pool.query(insertRequest,params);
    }))
}

(async function () {
    const pool = new Pool();

    await pool.query(clearAllRequest);

    await common.listFiles(common.path, common.filePattern).then(files => {
        return Promise.all(files.map(file => process_file(common.path, file, pool)))
    })

    await pool.end();
})().catch(error => {
    console.error(error)
});
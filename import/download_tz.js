const axios = require('axios')
const fs = require('fs').promises;
const {Pool} = require('pg')
const common = require('./common');

require('dotenv').config()

const user = '3182';
const authCode = '4a414eb687efcb6230f9b88782faac72cf02cad0a4d6d271cb370952d7d0d9ec';

const dateTimeMillis = 1577836800000; // Jan 1, 2020, 00:00:00 UTC

const selectAirportsRequest =
    "SELECT code, lat, lon FROM raw_airport WHERE (code like 'E%' or code like 'L%' or code = 'BKPR');";

async function getTz(lat, lon, dateTimeMillis, user, authCode) {
    return axios
        .get('https://api.askgeo.com/v1/' + user + '/' + authCode + '/query.json', {
            params: {
                databases: 'TimeZone',
                points: lat + ',' + lon,
                dateTime: dateTimeMillis
            },
        })
        .then(res => {
            console.log(`retrieved timezone for ` + lat + ', ' + lon)
            return res.data.data[0].TimeZone;
        })
}

async function saveTz(lat, lon, code) {
    let data = await getTz(lat, lon, dateTimeMillis, user, authCode)
    let fileName = common.generateTzFileName(code);
    console.log('writing ' + fileName)
    await fs.writeFile(fileName, JSON.stringify(data, null, 4));
}

(async () => {

    const pool = new Pool();

    await pool.query(selectAirportsRequest).then(res => {
        return Promise.all(res.rows.map(async row => saveTz(row.lat, row.lon, row.code)))
    })

    await pool.end();

})().catch(error => {
    console.error(error)
});
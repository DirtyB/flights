const axios = require('axios')
const fs = require('fs').promises;
const common = require('./common');

const testUser = 'test';
const testPassword = '123';

async function getAuthCode(username, password) {
    return axios
        .get('https://www.alarstudios.com/test/auth.cgi', {
            params: {
                username: username,
                password: password
            }
        })
        .then(res => {
            console.log(`retrieved authentication code`)
            return res.data.code;
        })
}

async function getPage(pageNumber, authCode) {
    return axios
        .get('http://www.alarstudios.com/test/data.cgi', {
            params: {
                p: pageNumber,
                code: authCode
            },
            responseType: 'text',
            transformResponse: []
        })
        .then(res => {
            console.log(`retrieved airports page ` + pageNumber)
            try {
                let parsedData = JSON.parse(res.data);
                if (parsedData.data.length === 0) {
                    console.log("page " + pageNumber + " has empty data")
                    return null;
                }
                return JSON.stringify(parsedData, null, 4);
            } catch (e) {
                console.warn("page " + pageNumber + " is invalid json");
                return res.data;
            }
        })
}

getAuthCode(testUser, testPassword).then(async code => {
    console.log(code)
    let pageNumber = 1;
    while(true) {
        let data = await getPage(pageNumber, code)
        if (data == null) {
            break;
        }
        await fs.writeFile(common.generateFileName(pageNumber), data);
        pageNumber++;
    }
}).catch(error => {
    console.error(error)
});
const axios = require('axios')
const fs = require('fs').promises;

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
            return res.data;
        })
}

function generateFileName(pageNumber) {
    return 'data/airports' + ('' + pageNumber).padStart(4, '0') + '.json';
}

getAuthCode(testUser, testPassword).then(async code => {
    console.log(code)
    let pageNumber = 1;
    return getPage(pageNumber, code).then(data => {
        console.log(data)
        return fs.writeFile(generateFileName(pageNumber), data);
    })
}).catch(error => {
    console.error(error)
});
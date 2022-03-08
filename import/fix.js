const fs = require('fs').promises;

const path = 'data';

const errorPattern1 = /"name":"([^"]+),"country"/g;
const errorReplacement1 = "\"name\":\"$1\",\"country\"";

const errorPattern2 = /"(\w+)"\s*:\s*([A-Za-z][^"]+)"?\s*([,}])/g;
const errorReplacement2 = "\"$1\": \"$2\"$3";

const errorPattern3 = "\"lon\": \"COM}\","
const errorReplacement3 = "\"lon\": \"COM\"},";


function listFiles() {
    return fs.readdir(path).then(files => {
        const re = /^airports\d{4}\.json$/;
        files = files.filter(value => {
            return value.match(re);
        })
        files.sort();
        // files.forEach(file => {
        //     console.log(file);
        // })
        return files;
    });
}

function isValidJson(data) {
    try {
        JSON.parse(data);
        return true;
    } catch (e) {
        return false;
    }
}

listFiles().then(files => {
    files.forEach(async file => {
        // console.log(file);
        let filePath = path + "/" + file;
        let data = await fs.readFile(filePath)
            .then(data => data.toString());
        if (!isValidJson(data)) {
            console.log("file " + file + " is not valid json, trying to fix");
            data = data.replaceAll(errorPattern1, errorReplacement1);
            data = data.replaceAll(errorPattern2, errorReplacement2);
            data = data.replaceAll(errorPattern3, errorReplacement3);
            if (isValidJson(data)) {
                console.log("file " + file + " fix OK, saving");
                let parsedData = JSON.parse(data);
                await fs.writeFile(filePath, JSON.stringify(parsedData, null, 4));
            } else {
                console.log("file " + file + " fix NOT OK, skipping");
            }
        }
    })
}).catch(error => {
    console.error(error)
});
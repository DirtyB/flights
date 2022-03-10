const fs = require('fs').promises;
const common = require('./common');

const errorPattern1 = /"name":"([^"]+),"country"/g;
const errorReplacement1 = "\"name\":\"$1\",\"country\"";

const errorPattern2 = /"(\w+)"\s*:\s*([A-Za-z][^"]+)"?\s*([,}])/g;
const errorReplacement2 = "\"$1\": \"$2\"$3";

const errorPattern3 = "\"lon\": \"COM}\","
const errorReplacement3 = "\"lon\": \"COM\"},";

function isValidJson(data) {
    try {
        JSON.parse(data);
        return true;
    } catch (e) {
        return false;
    }
}

function attemptFix(data) {
    data = data.replaceAll(errorPattern1, errorReplacement1);
    data = data.replaceAll(errorPattern2, errorReplacement2);
    return data.replaceAll(errorPattern3, errorReplacement3);
}

async function process_file(directory, file) {
    let filePath = directory + "/" + file;
    let data = await fs.readFile(filePath)
        .then(data => data.toString());
    if (!isValidJson(data)) {
        console.log("file " + file + " is not valid json, trying to fix");
        data = attemptFix(data);
        if (isValidJson(data)) {
            console.log("file " + file + " fix OK, saving");
            let parsedData = JSON.parse(data);
            await fs.writeFile(filePath, JSON.stringify(parsedData, null, 4));
        } else {
            console.log("file " + file + " fix NOT OK, skipping");
        }
    }
}

common.listFiles(common.path, common.filePattern).then(files => {
    return Promise.all(files.map(file => process_file(common.path, file)))
}).catch(error => {
    console.error(error)
});
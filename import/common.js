const fs = require('fs').promises;

const path = 'data';
const tz_path = 'tz_data';

module.exports.path = path;
module.exports.filePattern = /^airports\d{4}\.json$/

module.exports.tz_path = tz_path;
module.exports.tz_filePattern = /^([A-Z]{4})\.json$/

module.exports.generateFileName = function (pageNumber) {
    return path + '/airports' + ('' + pageNumber).padStart(4, '0') + '.json';
};

module.exports.generateTzFileName = function (code) {
    return tz_path + '/' + code + '.json';
};

const listFiles = function (directory, filePattern) {
    return fs.readdir(directory).then(files => {
        const re = filePattern;
        files = files.filter(value => {
            return value.match(re);
        })
        files.sort();
        return files;
    });
};

module.exports.listFiles = listFiles;

module.exports.apply_scripts = async function (dir, pool) {
    await listFiles(dir, /^.*\.sql$/).then(async files => {
        for (const file of files) {
            console.log('applying ' + file);
            let filePath = dir + "/" + file;
            let request = await fs.readFile(filePath)
                .then(data => data.toString());
            await pool.query(request);
        }
    })
}

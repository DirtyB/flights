const fs = require('fs').promises;

const path = 'data';

module.exports.path = path;
module.exports.filePattern = /^airports\d{4}\.json$/

module.exports.generateFileName = function (pageNumber) {
    return path + '/airports' + ('' + pageNumber).padStart(4, '0') + '.json';
}

module.exports.listFiles = function (directory, filePattern) {
    return fs.readdir(directory).then(files => {
        const re = filePattern;
        files = files.filter(value => {
            return value.match(re);
        })
        files.sort();
        return files;
    });
}

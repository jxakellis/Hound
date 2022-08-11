const bodyParser = require('body-parser');
const { ParseError } = require('./errors');
const { areAllDefined } = require('../format/validateDefined');

function parseFormData(req, res, next) {
  bodyParser.urlencoded({ extended: true })(req, res, (error) => {
    if (areAllDefined(error)) {
      return res.sendResponseForStatusJSONError(400, undefined, new ParseError('Unable to parse form data', global.constant.error.general.APP_BUILD_OUTDATED));
    }
    return next();
  });
}

function parseJSON(req, res, next) {
  bodyParser.json()(req, res, (error) => {
    if (areAllDefined(error)) {
      return res.sendResponseForStatusJSONError(400, undefined, new ParseError('Unable to parse json', global.constant.error.general.PARSE_JSON_FAILED));
    }

    return next();
  });
}

module.exports = { parseFormData, parseJSON };

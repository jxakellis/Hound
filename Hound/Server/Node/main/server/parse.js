const bodyParser = require('body-parser');
const { ParseError, convertErrorToJSON } = require('../tools/general/errors');

const parseFormData = (req, res, next) => {
  bodyParser.urlencoded({ extended: true })(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      // DONT ROLLBACK, CONNECTION NOT ASSIGNED
      return res.status(400).json(convertErrorToJSON(new ParseError('Unable to parse form data', global.constant.error.general.APP_BUILD_OUTDATED)));
    }
    return next();
  });
};

const parseJSON = (req, res, next) => {
  bodyParser.json()(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      // DONT ROLLBACK, CONNECTION NOT ASSIGNED
      return res.status(400).json(convertErrorToJSON(new ParseError('Unable to parse json', global.constant.error.general.PARSE_JSON_FAILED)));
    }

    return next();
  });
};

module.exports = { parseFormData, parseJSON };

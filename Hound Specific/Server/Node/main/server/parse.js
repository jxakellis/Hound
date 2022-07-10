const bodyParser = require('body-parser');
const { ParseError } = require('../tools/errors/parseError');

const parseFormData = (req, res, next) => {
  bodyParser.urlencoded({ extended: true })(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      // DONT ROLLBACK, CONNECTION NOT ASSIGNED
      return res.status(400).json(new ParseError('Unable to parse form data', global.constant.error.general.APP_BUILD_OUTDATED).toJSON);
    }
    return next();
  });
};

const parseJSON = (req, res, next) => {
  bodyParser.json()(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      // DONT ROLLBACK, CONNECTION NOT ASSIGNED
      return res.status(400).json(new ParseError('Unable to parse json', global.constant.error.general.PARSE_JSON_FAILED).toJSON);
    }

    return next();
  });
};

module.exports = { parseFormData, parseJSON };

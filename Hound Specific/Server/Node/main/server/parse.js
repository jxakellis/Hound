const bodyParser = require('body-parser');
const ParseError = require('../tools/errors/parseError');

const parseFormData = (req, res, next) => {
  bodyParser.urlencoded({ extended: true })(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      return res.status(400).json(new ParseError('Unable to parse form data', 'ER_NO_PARSE_FORM_DATA').toJSON);
    }
    return next();
  });
};

const parseJSON = (req, res, next) => {
  bodyParser.json()(req, res, (error) => {
    if (error) {
      // before creating a pool connection for request, so no need to release said connection
      return res.status(400).json(new ParseError('Unable to parse json', 'ER_NO_PARSE_JSON').toJSON);
    }

    return next();
  });
};

module.exports = { parseFormData, parseJSON };

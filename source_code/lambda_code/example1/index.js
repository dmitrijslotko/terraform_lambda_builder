const example = require("/opt/nodejs/utils/example");
exports.handler = (event) => {
  example.print(event);
};

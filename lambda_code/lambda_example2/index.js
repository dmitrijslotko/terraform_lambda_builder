let lambda_prefix = require("fs").existsSync("/opt/nodejs")
  ? "/opt/nodejs/"
  : "../layer/nodejs/";
const example = require(lambda_prefix + "custom_library_example");
exports.handler = async (event) => {
  return example.hello(event);
};

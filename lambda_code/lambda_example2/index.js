let lambda_prefix = process.env.lambda_prefix;
const example = require(lambda_prefix + "custom_library_example");
exports.handler = async (event) => {
  return example.hello(event);
};

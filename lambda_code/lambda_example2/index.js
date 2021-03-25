const config = require("config");
const env = config.util.getEnv("NODE_ENV");
console.log("env", env);
const layer_prefix = config.get("layer_prefix");
const example = require(layer_prefix + "custom_library_example");
exports.handler = async (event) => {
  return example.hello(event);
};

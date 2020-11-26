const example = require("/opt/nodejs/utils/custom_library_example");
exports.handler = async (event) => {
  example.print(event);
};

const uuid = require("uuid");
exports.handler = async () => {
  console.log(uuid.v4());
};

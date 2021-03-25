const uuid = require("uuid");
exports.handler = async () => {
  return uuid.v4();
};

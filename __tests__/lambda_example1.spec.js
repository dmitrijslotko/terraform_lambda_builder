const func = require("../lambda_code/lambda_example1/index");
describe("lambda_example1 test", () => {
  test("get random id", async () => {
    const response = await func.handler();
    expect.stringContaining(response);
  });
});

const func = require("../lambda_builder/lambda_code/lambda_example2/index");
describe("lambda_example2 test", () => {
  test("get hello world string", async () => {
    const response = await func.handler("from layer");
    expect(response).toBe(`hello world from layer`);
  });
});

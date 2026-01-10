import { FormatterFactory } from "../../lib/formatters/formatter_factory.js";
import { TestObject } from "./test_object.js";

test('test integrate fasta headers', async () => {
  const formatter = FormatterFactory.getFormatter("csv");
  const fasta = { 5: ">test" };
  const object = [TestObject.testObject(), TestObject.testObject()];
  const integrated = [Object.assign({ fasta_header: ">test" }, TestObject.testObject()), Object.assign({ fasta_header: ">test" }, TestObject.testObject())];
  // @ts-ignore
  expect(formatter.integrateFastaHeaders(object, fasta)).toEqual(integrated);
});

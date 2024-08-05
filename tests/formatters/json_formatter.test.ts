import { FormatterFactory } from "../../lib/formatters/formatter_factory";
import { TestObject } from "./test_object";

const formatter = FormatterFactory.getFormatter("json");

test('test header', () => {
  const object = [TestObject.testObject(), TestObject.testObject()];
  expect(formatter.header(object)).toBe("[");
});

test('test footer', () => {
  expect(formatter.footer()).toBe("]\n");
});

test('test convert', () => {
  const object = [TestObject.testObject()];
  const json = TestObject.asJson();

  expect(formatter.convert(object, true)).toBe(json);
  expect(formatter.convert(object, false)).toBe(`,${json}`);
});

test('test format with fasta', () => {
  const fasta = { 5: ">test" };
  const object = [TestObject.testObject()];
  const json = '{"fasta_header":">test","integer":5,"string":"string","list":["a",2,false]}';
  expect(formatter.format(object, fasta, true)).toBe(json);
});

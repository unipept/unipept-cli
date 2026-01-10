import { FormatterFactory } from "../../lib/formatters/formatter_factory.js";
import { TestObject } from "./test_object.js";

const formatter = FormatterFactory.getFormatter("csv");

test('test header', () => {
  const object = [TestObject.testObject(), TestObject.testObject()];
  expect(formatter.header(object)).toBe(TestObject.asCsvHeader());
});

test('test footer', () => {
  expect(formatter.footer()).toBe("");
});

test('test convert', () => {
  const object = [TestObject.testObject(), TestObject.testObject()];
  const csv = [TestObject.asCsv(), TestObject.asCsv(), ""].join("\n");

  expect(formatter.convert(object, true)).toBe(csv);
  expect(formatter.convert(object, false)).toBe(csv);
});

test('test format with fasta', () => {
  const fasta = { 5: ">test" };
  const object = [TestObject.testObject(), TestObject.testObject()];
  const csv = [`>test,${TestObject.asCsv()}`, `>test,${TestObject.asCsv()}`, ""].join("\n");
  expect(formatter.format(object, fasta, false)).toBe(csv);
});

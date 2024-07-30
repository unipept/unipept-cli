import { FormatterFactory } from "../../lib/formatters/formatter_factory";
import { TestObject } from "./test_object";

const formatter = FormatterFactory.getFormatter("csv");

test('test header', () => {
  const fasta = [["peptide", ">test"]];
  const object = [TestObject.testObject(), TestObject.testObject()];
  expect(formatter.header(object)).toBe(TestObject.asCsvHeader());
  //expect(formatter.header(object, fasta)).toBe(`fasta_header,${TestObject.asCsvHeader()}`);
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
  const fasta = [['>test', '5']];
  const object = [TestObject.testObject(), TestObject.testObject()];
  const csv = [`>test,${TestObject.asCsv()}`, TestObject.asCsv(), ""].join("\n");
  //expect(formatter.format(object, fasta, false)).toBe(csv);
});

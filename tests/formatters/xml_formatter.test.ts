import { FormatterFactory } from "../../lib/formatters/formatter_factory.js";
import { TestObject } from "./test_object.js";

const formatter = FormatterFactory.getFormatter("xml");

test('test header', () => {
  const object = [TestObject.testObject(), TestObject.testObject()];
  expect(formatter.header(object)).toBe("<results>");
});

test('test footer', () => {
  expect(formatter.footer()).toBe("</results>\n");
});

test('test convert', () => {
  const object = [TestObject.testObject()];
  const xml = `<result>${TestObject.asXml()}</result>`;

  expect(formatter.convert(object, true)).toBe(xml);
  expect(formatter.convert(object, false)).toBe(xml);
});

test('test format with fasta', () => {
  const fasta = { 5: ">test" };
  const object = [TestObject.testObject()];
  const xml = `<result><fasta_header>&gt;test</fasta_header>${TestObject.asXml()}</result>`;
  expect(formatter.format(object, fasta, true)).toBe(xml);
});

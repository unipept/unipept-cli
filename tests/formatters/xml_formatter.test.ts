import { FormatterFactory } from "../../lib/formatters/formatter_factory";
import { TestObject } from "./test_object";

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
  //const fasta = [['>test', '5']];
  //const object = [TestObject.testObject()];
  //const json = '{"fasta_header":">test","integer":5,"string":"string","list":["a",2,false]}';
  //expect(formatter.format(object, fasta, true)).toBe(json);
});

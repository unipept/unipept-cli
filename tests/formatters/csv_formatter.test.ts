import { CSVFormatter } from "../../lib/formatters/csv_formatter.js";
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

test('test flatten collapses annotations into columns', () => {
  const data = [{ peptide: "AAA", ec: [{ ec_number: "1.1.1.1", protein_count: 3 }, { ec_number: "2.2.2.2", protein_count: 1 }] }];

  expect((formatter as CSVFormatter).flatten(data)).toStrictEqual([
    { peptide: "AAA", ec_number: "1.1.1.1 2.2.2.2", ec_protein_count: "3 1" }
  ]);
});

test('test flatten with a peptide without annotations', () => {
  // peptides that match no enzymes come back with an empty ec array, and that peptide
  // can be the first of a batch, so the columns must be derived from any row that has them
  const data = [
    { peptide: "AAA", ec: [] },
    { peptide: "BBB", ec: [{ ec_number: "1.1.1.1", protein_count: 3 }] },
  ];

  expect((formatter as CSVFormatter).flatten(data)).toStrictEqual([
    { peptide: "AAA", ec_number: "", ec_protein_count: "" },
    { peptide: "BBB", ec_number: "1.1.1.1", ec_protein_count: "3" },
  ]);
});

test('test flatten when no peptide has annotations', () => {
  const data = [{ peptide: "AAA", ec: [] }];

  expect((formatter as CSVFormatter).flatten(data)).toStrictEqual([{ peptide: "AAA" }]);
});

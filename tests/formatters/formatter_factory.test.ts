import { FormatterFactory } from "../../lib/formatters/formatter_factory";

test('test if default formatter is csv', async () => {
  const formatter = FormatterFactory.getFormatter("foo");
  expect(formatter.constructor.name).toBe("CSVFormatter");
});

test('test if csv formatter is csv', async () => {
  const formatter = FormatterFactory.getFormatter("csv");
  expect(formatter.constructor.name).toBe("CSVFormatter");
});

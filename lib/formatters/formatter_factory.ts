import { CSVFormatter } from "./csv_formatter.js";
import { Formatter } from "./formatter.js";

export class FormatterFactory {
  static getFormatter(name: string): Formatter {
    if (name === "csv") {
      return new CSVFormatter();
    }
    return new CSVFormatter();
  }
}

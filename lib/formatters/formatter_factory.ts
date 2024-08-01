import { CSVFormatter } from "./csv_formatter.js";
import { Formatter } from "./formatter.js";
import { JSONFormatter } from "./json_formatter.js";

export class FormatterFactory {
  static getFormatter(name: string): Formatter {
    if (name === "csv") {
      return new CSVFormatter();
    } else if (name === "json") {
      return new JSONFormatter();
    }
    return new CSVFormatter();
  }
}

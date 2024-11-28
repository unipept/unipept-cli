import { Formatter } from "./formatter.js";
import { CSVFormatter } from "./csv_formatter.js";
import { JSONFormatter } from "./json_formatter.js";
import { XMLFormatter } from "./xml_formatter.js";

export class FormatterFactory {
  static getFormatter(name: string): Formatter {
    if (name === "csv") {
      return new CSVFormatter();
    } else if (name === "json") {
      return new JSONFormatter();
    } else if (name === "xml") {
      return new XMLFormatter();
    }
    return new CSVFormatter();
  }
}

import { Formatter } from "./formatter.js";
import { stringify } from "csv-stringify/sync";

export class CSVFormatter extends Formatter {

  header(sampleData: { [key: string]: string }[], fastaMapper?: boolean | undefined): string {
    return stringify([this.getKeys(sampleData, fastaMapper)]);
  }

  footer(): string {
    return "";
  }

  convert(data: object[]): string {
    return stringify(data);
  }

  getKeys(data: { [key: string]: unknown }[], fastaMapper?: boolean | undefined): string[] {
    return fastaMapper ? ["fasta_header", ...Object.keys(data[0])] : Object.keys(data[0]);
  }

  flatten(data: { [key: string]: unknown }[]): { [key: string]: unknown }[] {
    const prefixes = ["ec", "go", "ipr"];
    prefixes.forEach(prefix => {
      if (this.getKeys(data).includes(prefix)) {// @ts-ignore
        const keys = Object.keys(data[0][prefix][0]);
        data.forEach(row => {
          keys.forEach(key => {
            const newKey = key.startsWith(prefix) ? key : `${prefix}_${key}`;
            // @ts-ignore
            row[newKey] = row[prefix].map(e => e[key]).join(" ");
          });
          delete row[prefix];
        });
      }
    });
    return data;
  }
}

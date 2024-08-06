import { Formatter } from "./formatter.js";
import { stringify } from "csv-stringify/sync";

export class CSVFormatter extends Formatter {

  header(sampleData: { [key: string]: string }[], fastaMapper?: boolean | undefined): string {
    return stringify([this.getKeys(this.flatten(sampleData), fastaMapper)]);
  }

  footer(): string {
    return "";
  }

  convert(data: object[]): string {
    return stringify(this.flatten(data as { [key: string]: unknown }[]));
  }

  getKeys(data: { [key: string]: unknown }[], fastaMapper?: boolean | undefined): string[] {
    return fastaMapper ? ["fasta_header", ...Object.keys(data[0])] : Object.keys(data[0]);
  }

  flatten(data: { [key: string]: unknown }[]): { [key: string]: unknown }[] {
    if (this.getKeys(data).includes("ec")) {
      // @ts-ignore
      const keys = Object.keys(data[0].ec[0]);
      data.forEach(row => {
        keys.forEach(key => {
          const newKey = key.startsWith("ec") ? key : `ec_${key}`;
          // @ts-ignore
          row[newKey] = row.ec.map(e => e[key]).join(" ");
        });
        delete row.ec;
      });
    }
    return data;
  }
}

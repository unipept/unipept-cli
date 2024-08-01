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

  getKeys(data: { [key: string]: string }[], fastaMapper?: boolean | undefined): string[] {
    return fastaMapper ? ["fasta_header", ...Object.keys(data[0])] : Object.keys(data[0]);
  }
}

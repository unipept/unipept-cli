import { CSVFormatter } from "./csv_formatter.js";

export abstract class Formatter {

  abstract header(sampleData: object, fastaMapper?: boolean): string;
  abstract footer(): string;
  abstract convert(data: any, first?: boolean): string;

  format(data, fastaMapper?: boolean, first?: boolean): string {
    if (fastaMapper) {
      data = this.integrateFastaHeaders(data, fastaMapper);
    }
    return this.convert(data, first);
  }

  integrateFastaHeaders(data: any, fastaMapper: boolean): any {
    return data;
  }
}

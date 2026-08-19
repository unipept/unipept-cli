import { Formatter } from "./formatter.js";
import { stringify } from "csv-stringify/sync";

/** A single ec, go or ipr annotation as returned by the Unipept API. */
type Annotation = { [key: string]: unknown };

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

  /**
   * Collapses the nested annotation arrays (ec, go, ipr) into space separated columns,
   * so that every result stays a single flat CSV row.
   */
  flatten(data: { [key: string]: unknown }[]): { [key: string]: unknown }[] {
    const prefixes = ["ec", "go", "ipr"];
    prefixes.forEach(prefix => {
      if (this.getKeys(data).includes(prefix)) {
        // the annotations of a peptide can be empty, so look for the first row that has any
        const keys = data
          .map(row => (row[prefix] as Annotation[])[0])
          .filter(annotation => annotation !== undefined)
          .map(annotation => Object.keys(annotation))[0] ?? [];

        data.forEach(row => {
          const annotations = row[prefix] as Annotation[];
          keys.forEach(key => {
            const newKey = key.startsWith(prefix) ? key : `${prefix}_${key}`;
            row[newKey] = annotations.map(annotation => annotation[key]).join(" ");
          });
          delete row[prefix];
        });
      }
    });
    return data;
  }
}

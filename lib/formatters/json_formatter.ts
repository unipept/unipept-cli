import { Formatter } from "./formatter.js";

export class JSONFormatter extends Formatter {

  header(_sampleData: { [key: string]: string }[], _fastaMapper?: boolean | undefined): string {
    return "[";
  }

  footer(): string {
    return "]\n";
  }

  convert(data: object[], first: boolean): string {
    const output = data.map(d => JSON.stringify(d)).join(",");
    return first ? output : `,${output}`;
  }
}

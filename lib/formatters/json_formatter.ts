import { Formatter } from "./formatter.js";

export class JSONFormatter extends Formatter {

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  header(sampleData: { [key: string]: string }[], fastaMapper?: boolean | undefined): string {
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

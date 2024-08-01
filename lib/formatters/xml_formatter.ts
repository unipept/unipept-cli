import { Formatter } from "./formatter.js";
import { toXML } from "to-xml";

export class XMLFormatter extends Formatter {

  header(_sampleData: { [key: string]: string }[], _fastaMapper?: boolean | undefined): string {
    return "<results>";
  }

  footer(): string {
    return "</results>\n";
  }

  convert(data: object[], _first: boolean): string {
    return data.map(d => `<result>${toXML(d)}</result>`).join("");
  }
}

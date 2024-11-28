export abstract class Formatter {

  abstract header(sampleData: object, fastaMapper?: boolean): string;
  abstract footer(): string;
  abstract convert(data: object[], first?: boolean): string;

  format(data: object[], fastaMapper?: { [key: string]: string }, first?: boolean): string {
    if (fastaMapper) {
      data = this.integrateFastaHeaders(data as { [key: string]: string }[], fastaMapper);
    }
    return this.convert(data, first);
  }

  integrateFastaHeaders(data: { [key: string]: string }[], fastaMapper: { [key: string]: string }): object[] {
    const key = Object.keys(data[0])[0];
    data.forEach((entry, i) => {
      data[i] = Object.assign({ fasta_header: fastaMapper[entry[key]] }, entry);
    });
    return data;
  }
}

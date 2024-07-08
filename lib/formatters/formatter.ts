export abstract class Formatter {

  abstract header(sampleData: object, fastaMapper?: boolean): string;
  abstract footer(): string;
  abstract convert(data: { [key: string]: string }[], first?: boolean): string;

  format(data: { [key: string]: string }[], fastaMapper?: boolean, first?: boolean): string {
    if (fastaMapper) {
      data = this.integrateFastaHeaders(data, fastaMapper);
    }
    return this.convert(data, first);
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  integrateFastaHeaders(data: { [key: string]: string }[], fastaMapper: boolean): { [key: string]: string }[] {
    return data;
  }
}

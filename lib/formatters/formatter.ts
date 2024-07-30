export abstract class Formatter {

  abstract header(sampleData: object, fastaMapper?: boolean): string;
  abstract footer(): string;
  abstract convert(data: object[], first?: boolean): string;

  format(data: object[], fastaMapper?: boolean, first?: boolean): string {
    if (fastaMapper) {
      data = this.integrateFastaHeaders(data, fastaMapper);
    }
    return this.convert(data, first);
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  integrateFastaHeaders(data: object[], fastaMapper: boolean): object[] {
    return data;
  }
}

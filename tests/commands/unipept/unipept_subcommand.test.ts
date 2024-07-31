import { Interface } from 'readline';
import { Pept2lca } from '../../../lib/commands/unipept/pept2lca';

test('test command setup', () => {
  const command = new Pept2lca();
  expect(command.name).toBe("pept2lca");
  expect(command.user_agent).toMatch(/^unipept-cli/);
  expect(command.command.name()).toBe("pept2lca");
});

test('test correct host', () => {
  const command = new Pept2lca();

  expect(command.host).toBe("https://api.unipept.ugent.be");
  expect(command["getHost"]()).toBe("https://api.unipept.ugent.be");

  command.options.host = "https://optionshost";
  expect(command["getHost"]()).toBe("https://optionshost");

  command.options.host = "http://optionshost";
  expect(command["getHost"]()).toBe("http://optionshost");

  command.options.host = "optionshost";
  expect(command["getHost"]()).toBe("http://optionshost");
});

test('test correct inputIterator', async () => {
  const command = new Pept2lca();

  // should be stdin
  let input = command["getInputIterator"]([]) as Interface;
  expect(input).toBeInstanceOf(Interface);
  input.close();

  // should be a (non-existant) file and error
  input = command["getInputIterator"]([], "filename") as Interface;
  input.on("error", (e) => {
    expect(e.toString()).toMatch(/no such file/);
  });

  // should be array
  const inputArray = command["getInputIterator"](["A", "B"]);
  expect(inputArray).toBeInstanceOf(Array);
});

test('test selected fields parsing', () => {
  const command = new Pept2lca();

  command.options.select = ["a,b,c"];
  expect(command["getSelectedFields"]()).toStrictEqual([/^a$/, /^b$/, /^c$/]);
});

test('test selected fields with wildcards', () => {
  const command = new Pept2lca();

  command.options.select = ["taxon*,name"];
  expect(command["getSelectedFields"]()).toStrictEqual([/^taxon.*$/, /^name$/]);
});

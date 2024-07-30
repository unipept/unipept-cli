import { Unipept } from '../../lib/commands/unipept';

test('test single argument', async () => {
  const command = new Unipept();
  const commandNames = command.program.commands.map(c => c.name());
  expect(commandNames).toContain("pept2lca");
});

import { Unipept } from '../../lib/commands/unipept.js';

test('test if all commands are available', async () => {
  const command = new Unipept();
  const commandNames = command.program.commands.map(c => c.name());
  expect(commandNames).toContain("pept2lca");
});

import path from 'path';
import { Polly } from '@pollyjs/core';
import NodeHttpAdapter from '@pollyjs/adapter-fetch';
import FSPersister from '@pollyjs/persister-fs';
import { fileURLToPath } from 'url';

Polly.register(NodeHttpAdapter);
Polly.register(FSPersister);

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function setupPolly(recordingName: string) {
  const mode = process.env.POLLY_MODE || 'replay';

  return new Polly(recordingName, {
    adapters: ['fetch'],
    persister: 'fs',
    persisterOptions: {
      fs: {
        recordingsDir: path.resolve(__dirname, '../recordings'),
      },
    },
    // Default to replay, but record if missing.
    // This allows CI to just replay, but local devs can generate missing recordings.
    mode: mode as any,
    recordIfMissing: true,
    flushRequestsOnStop: true,
  });
}

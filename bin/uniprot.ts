#!/usr/bin/env node

import { Uniprot } from '../lib/commands/uniprot.js';

const command = new Uniprot();
command.run();

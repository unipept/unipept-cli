# unipept-cli

![NPM Version](https://img.shields.io/npm/v/unipept-cli)

Unipept-cli offers a command line interface to the [Unipept](http://unipept.ugent.be) web service.
Documentation about the web service can be found at [http://unipept.ugent.be/apidocs](http://unipept.ugent.be/apidocs), documentation about the command line tools at [http://unipept.ugent.be/clidocs](http://unipept.ugent.be/clidocs).

## Installation

To use the Unipept CLI, node 22 or higher needs to be installed. You can check this by running `node -v` on the commandline:

```
$ node -v
v22.3.0
```

More information on installing Ruby can be found at https://nodejs.org/en/download/package-manager

The Unipept CLI is available as an npm package. This means it can easily be installed with the following command:

```bash
$ npm install -g unipept-cli
added 3 packages in 986ms
```

After successful installation, the unipept command should be available:

```bash
$ unipept -v
4.0.0
```

The help can be accessed by running `unipept -h`.

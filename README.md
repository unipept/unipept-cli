# unipept-cli

[![Gem Version](https://badge.fury.io/rb/unipept.svg)](http://badge.fury.io/rb/unipept)

Unipept-cli offers a command line interface to the [Unipept](http://unipept.ugent.be) web service.
Documentation about the web service can be found at [http://unipept.ugent.be/apidocs](http://unipept.ugent.be/apidocs), documentation about the command line tools at [http://unipept.ugent.be/clidocs](http://unipept.ugent.be/clidocs).

## Installation

To use the Unipept CLI, Ruby version 2.6 or higher needs to be installed. You can check this by running `ruby -v` on the commandline:

```
$ ruby -v
ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [arm64-darwin21]
```

More information on installing Ruby can be found at https://www.ruby-lang.org/en/installation/

The Unipept CLI is available as a _gem_. This means it can easily be installed with the following command:

```bash
$ gem install unipept
Successfully installed unipept-1.0.1
Parsing documentation for unipept-1.0.1
Done installing documentation for unipept after 0 seconds
1 gem installed
```

After successful installation, the unipept command should be available:

```bash
$ unipept -v
1.0.1
```

The help can be accessed by running `unipept -h`.

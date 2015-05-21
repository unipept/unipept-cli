# unipept-cli

[![Gem Version](https://badge.fury.io/rb/unipept.svg)](http://badge.fury.io/rb/unipept)
[![Build Status](https://api.travis-ci.org/unipept/unipept-cli.svg)](https://travis-ci.org/unipept/unipept-cli)
[![Code Climate](https://codeclimate.com/github/unipept/unipept-cli/badges/gpa.svg)](https://codeclimate.com/github/unipept/unipept-cli)

Unipept-cli offers a command line interface to the [Unipept](http://unipept.ugent.be) web service.
Documentation about the web service can be found at [http://unipept.ugent.be/apidocs](http://unipept.ugent.be/apidocs).

## Installation

To use the Unipept CLI, Ruby version 1.9.3 or higher needs to be installed. You can check this by running `ruby -v` on the commandline:

```
$ ruby -v
ruby 2.1.1p76 (2014-02-24 revision 45161) [x86_64-darwin12.0]
```

More information on installing Ruby can be found at https://www.ruby-lang.org/en/installation/

The Unipept CLI is available as a *gem*. This means it can easily be installed with the following command:

```bash
$ gem install unipept
Successfully installed unipept-0.7.1
Parsing documentation for unipept-0.7.1
Done installing documentation for unipept after 0 seconds
1 gem installed
```

After successful installation, the unipept command should be available:

```bash
$ unipept -v
0.7.1
```

The help can be accessed by running `unipept -h`.

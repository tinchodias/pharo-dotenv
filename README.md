# pharo-dotenv
Pharo package that loads environment variables from a .env file into the process environment variables.

It is a basic port of the [nodejs dotenv module](https://github.com/motdotla/dotenv).

## Install

In Pharo 6.1 or 7.0, add this repository to Iceberg and load the only package. It has no Metacello baseline for the moment.

## Use

### Basic

If you have a `.env` file in the `FileSystem workingDirectory` with this content:
~~~
VAR1=var1
VAR2=var2
~~~

Then, you can read values with:

~~~
Dotenv new variablesDictionary.
>>> "a Dictionary('VAR1'->'var1' 'VAR2'->'var2' )"
~~~

### Apply to process environment variables

This is the scenario that the original dotenv project considers. 

For example, if you run your web system in 2 different contexts:
* production: the environment variables USERNAME and PASSWORD define some credentials.
* development: the `.env` file defines both variables as in the Basic example shown above.

~~~
Dotenv new config.

credentials := Credentials
    username: (OSPlatform current environment at: 'USERNAME')
    password: (OSPlatform current environment at: 'PASSWORD').
~~~


### Specify a custom path

This example works if you have the variables defined in `~/.credentials`:

~~~
Dotenv new
  path: (FileLocator home / '.credentials') asFileReference;
  config.
~~~


### More

Browse `DotenvTest` class for more usage details.

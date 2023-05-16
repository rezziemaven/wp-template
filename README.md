# WP Templates
This is a CLI that adds a README, `.gitignore` or `composer.json` file to your custom WordPress theme or plugin to make your WordPress asset compatible with Composer and/or Bedrock.

- Requires: [coreutils](https://formulae.brew.sh/formula/coreutils). This enables the `-f` option in the `readlink` command to work. Note: this is not required if using MacOS v12.3 or greater or if using Linux systems. You can install it from your terminal using the command `brew install coreutils`.
- Tested on: MacOS v10.15.7

The CLI uses the following syntax:
`wp-template [-h|mu|p|t|V] [-a|i|m] [replace-string]`

The options include:
- `h`:     Shows the Help for the CLI.
- `mu`:    Copy the mu-plugin `composer.json` template.
- `p`:     Copy the plugin `composer.json` template.
- `t`:     Copy the theme `composer.json` template.
- `V`:     Prints the software version and exits.
- `a`:     Automatic mode. Adds in any of the missing recommended files.
- `i`:     Interactive mode. Includes the missing recommended files with step by step prompts.
- `m`:     Manual mode (lets you update the template files yourself).
- `replace-string`:     Replaces the default name of plugin or theme in composer.json file with custom name.

## Installation
**NB:** These installation instructions work on Mac OS. The instructions may work in similar fashion on Linux or Windows, or you may need to use equivalent commands.

1. Clone this repository to your system.
2. Make the script in the root folder a CLI by making a symlink of the script to the path where your other commands are stored:
   1. The path you will want to make the symlink in will most likely `/usr/local/bin`, but you can verify which directories are in your `$PATH` and the correct path to use with the command `echo $PATH | tr \: \\n`.
   2. Find the path for the root folder of the `wp-template.sh` file using `pwd` in your terminal.
   3. Enter the command ```ln -s `pwd`/wp-template.sh /path/to/directory/wp-template``` from the root folder of this project. For example, if you'd like to add a symlink of the script located in `~/wp-template` to `/usr/local/bin`, type the command ```ln -s `pwd`/wp-template.sh /usr/local/bin/wp-template```.

You should now be able to use the command `wp-template` in the root folder of your WordPress theme or plugin and easily add the missing recommended files to it. Enjoy!


#!/bin/bash
VERSION=1.0.1
################################################################################
#                              wp-template                                  #
#                                                                              #
# Copies .gitignore and composer.json templates to a WordPress plugin or theme #                                            #
#                                                                              #
# Change History                                                               #
# 22/02/2023  Sherezz Grant   Original code.                                   #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
################################################################################
################################################################################
################################################################################
#                                                                              #
#  Copyright (C) 2023 Sherezz Grant                                            #
#  rezziemaven@gmail.com                                                       #
#                                                                              #
#  This program is free software; you can redistribute it and/or modify        #
#  it under the terms of the GNU General Public License as published by        #
#  the Free Software Foundation; either version 2 of the License, or           #
#  (at your option) any later version.                                         #
#                                                                              #
#  This program is distributed in the hope that it will be useful,             #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of              #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
#  GNU General Public License for more details.                                #
#                                                                              #
#  You should have received a copy of the GNU General Public License           #
#  along with this program; if not, write to the Free Software                 #
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   #
#                                                                              #
################################################################################
################################################################################
################################################################################

################################################################################
# Help                                                                         #
################################################################################

Help()
{
  # Display Help
  echo "This is a script for copying the .gitignore and composer.json templates and adding a README to a WordPress plugin or theme."
  echo
  echo "Syntax: wp-template [-h|mu|p|t|V] [-a|i|m] [replace-string]"
  echo "Options:"
  # echo "g     Print the GPL license notification."
  echo "h     Print this Help."
  echo "mu    Copy the mu-plugin composer.json template."
  echo "p     Copy the plugin composer.json template."
  echo "t     Copy the theme composer.json template."
  echo "V     Print software version and exit."
  echo "a     Automatic mode."
  echo "i     Interactive mode."
  echo "m     Manual mode (lets you update the template files yourself)."
  echo "replace-string     Replace default name of plugin or theme in composer.json file with custom name."
  echo
}

################################################################################
# Interactive mode                                                             #
################################################################################
InteractiveMode()
# Initiate interactive dialogue
{
  echo "Update $1 description"
  read local description
  echo "Update $1 version"
  read local version
  echo "Update author name"
  read local author
  echo "Update author URI"
  read local authorURI
  sed -i "" -e "s/Change description here/$description/g" -e "s/1.0.0/$version/g" -e "s/Author One/$author/" -e "s,https://authorone.com/,$authorURI," composer.json
}

################################################################################
# Automatic mode                                                               #
################################################################################
AutomaticMode()
# Automatically update composer.json
{
  # Store Description from file in variable
  local description="$(GetTrimmedStringFrom "Description")"
  # Store Version from file in variable
  local version="$(GetTrimmedStringFrom "Version")"
  # Store Author from file in variable
  local author="$(GetTrimmedStringFrom "Author")"
  # Store Author URI from file in variable
  local authorURI="$(GetTrimmedStringFrom "Author URI")"
  # Replace dummy content in composer.json with stored variables
  sed -i "" -e "s/Change description here/$description/" -e "s/1.0.0/$version/" -e "s/Author One/$author/" -e "s,https://authorone.com/,$authorURI," composer.json
}

################################################################################
# Readme Prompt                                                                #
################################################################################
AddReadme()
{
  local option=$1
  # Adds Readme to folder

  if [ "$option" = "blank" ]; then
    # add Blank Readme to folder
    touch README.md
    echo README created.
    break
  elif [ "$option" = "interactive" ]; then
    echo "Add $pluginOrTheme name"
    read readmeHeading
    echo "# $readmeHeading" >> README.md
    echo "Add $pluginOrTheme description"
    read readmeDescription
    echo -e "# $readmeHeading\n$readmeDescription" > README.md
  else
    # Store plugin name
    pluginName="$(GetTrimmedStringFrom "Plugin Name")"
    # Store description if variable doesn't already exist
    [ -z "$description" ] && description="$(GetTrimmedStringFrom "Description")"
    # Add plugin name and description to README.md
    echo -e "# $pluginName\n$description" > README.md
  fi
  echo README created. Please check file to ensure contents are correct.
  filesAdded=$((filesAdded+1))
}

PHPPrompt()
{
  # Prompt for PHP file name containing plugin header
  # Track number of tries
  local tries=1
  local prompt="Name of PHP file containing plugin header [press Enter to accept default: ${newFolderName}]"
  # local newFolderName=$1
  Prompt()
  {
    if [ $tries -lt 4 ]; then
      [ $tries -eq 1 ] && echo "$prompt" || echo "[$tries/3] $prompt"
      read pluginFilename
      # Use folder name (without suffix) if no name was entered
      if [ -z "$pluginFilename"]; then
        pluginFilename=$newFolderName
        echo "plugin filename is $pluginFilename"
      fi
      # Add .php if not included
      [[ ! $pluginFilename =~ ".php" ]] && pluginFilename="$pluginFilename.php"
      if [ -f "$pluginFilename" ]; then
        # Exit function and go to next step in main code
        return
      else
        tries=$((tries+1))
        echo Invalid filename. Try again.
        Prompt
      fi
    else
      echo Invalid filename. Exiting.
      rm ./composer.json
      exit
    fi
  }
  Prompt
}

GetTrimmedStringFrom()
{
  # Sanitises string result from a property in plugin header
  echo "$(awk -v pat="$1:" '-F: ' '$0 ~ pat { print $2 }' $pluginFilename | xargs | tr -d '\r')"
}

Error()
{
  echo Error: Not a valid argument. Please use -h to see the available options.
}

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

pluginOrTheme=plugin
filesAdded=0
SCRIPTPATH=$(greadlink -f `which wp-template`)
SCRIPTDIR=$(dirname $SCRIPTPATH)
echo $(pwd)
# Show Help if no arguments were added.
if [ "$#" -eq 0 ]; then
  Help
  exit
fi
for arg in "$@"; do
  # First arg options
  if [ "$1" = "-mu" -o "$1" = "-p" -o "$1" = "-t" ] ; then
    # Add .gitignore if not in folder
    if [ ! -e "`pwd`/.gitignore" ] ; then
      cp "$SCRIPTDIR/templates/.gitignore" ./.gitignore
      echo .gitignore added.
      filesAdded=$((filesAdded+1))
    fi
    # Add composer.json if not in folder
    if [ ! -e "`pwd`/composer.json" ] ; then
      if [ "$1" = "-mu" ]; then
        cp "$SCRIPTDIR/templates/mu-plugin-composer.json" ./composer.json
      elif [ "$1" = "-p" ]; then
        cp "$SCRIPTDIR/templates/plugin-composer.json" ./composer.json
      elif [ "$1" = "-t" ]; then
        $pluginOrTheme=theme
        cp "$SCRIPTDIR/templates/theme-composer.json" ./composer.json
      elif [ -z "$1" ]; then
        break
      fi
      echo Composer file added.
      filesAdded=$((filesAdded+1))
      # Prompt for PHP file name containing plugin header
      if [ -z "$2" -o "$2" = "-a" -o "$2" = "-i" ]; then

        # Modify name and homepage in composer.json file
        [ -z "$3" ] && FOLDER="$(basename $PWD)" || FOLDER="$3"
        # Only copy folder name without -3p or -mu
        newFolderName="$(echo $FOLDER | sed 's/-[3m][pu]//')"
        PHPPrompt
        sed -i "" "s/name-of-$pluginOrTheme/$FOLDER/g" composer.json
        # Modify new path for plugin or theme in composer.json file
        sed -i "" "s/new-folder-name/$newFolderName/" composer.json
        case "$2" in
          -a|"")
            AutomaticMode
            ;;
          -i)
            InteractiveMode $pluginOrTheme
            ;;
        esac
        echo Composer file updated. Please check file to ensure contents are correct.

      # Skip PHP Prompt if in manual mode
      elif [ "$2" = "-m" ]; then
        # ReadmePrompt "blank"
        break
      else
        Error
        break
      fi
    fi
    # Add README.md if not in folder
    readme="$(find . -maxdepth 1 -type f -iname "readme*" -prune)"
    if [ ! -z "$readme" ] ; then
      # Replace readme.txt with README.md
      readmeToLower="$(echo $readme | tr '[:upper:]' '[:lower:]')"
      [[ "$readmeToLower" = *"readme.txt"* ]] && $(mv $readme README.md) && echo README created from readme.txt && filesAdded=$((filesAdded+1))
    else
      # Show PHP prompt if plugin filename wasn't already set
      [ -z $pluginFilename ] && PHPPrompt
      # Add Readme
      case "$2" in
        -a|"")
          AddReadme "auto"
          break;;
        -i)
          AddReadme "interactive"
          break;;
        -m|"")
          AddReadme "blank"
          break;;
      esac
    fi
    # If recommended files already exist, exit
    [ "$filesAdded" -eq 0 ] && echo "Recommended files already in folder. Exiting."
    #Other first arg options
    elif [ "$1" = "-h" ]; then
      Help
      exit
    elif [ "$1" = "-V" ]; then
      echo $VERSION
      exit
    else
      Error
      exit
    fi
  break
done

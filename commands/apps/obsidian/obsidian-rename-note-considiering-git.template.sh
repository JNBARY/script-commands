#!/bin/bash
#!/usr/local/bin/obsidian

# How to use this script?
# It's a template which needs further setup. Duplicate the file, 
# remove `.template.` from the filename and set vaultPath to your Obsidian Vault.

# Note: Obsidian v0.8.15+ required
# Install via: 1) https://obsidian.md 2) brew install --cask obsidian


# Parameters 

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rename Obsidian-Note while keeping git-history
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "New file name"}

# Documentation:
# @raycast.description Rename the Obsidian-Note currently sected in the frontmost finder window and stored in a Vault that is a git-repository by both updating links to the renamed note with the new name and keeping the git-history of the renamed note. 
# @raycast.author JNBARY


# Configuration:
# Path to the Obsidian-Vault you want to act on:
vaultPath="/Users/JNBARY/Obsidian"


# Main program
cd $vaultPath

# check if Vault is a git-directory
if [ ! -d .git ];
then
  echo "Error: $vaultPath is no git-directory"
  exit 1
fi


# Get Finder selection
oldPath=$(osascript <<'EOF'
tell application "Finder"
  return "" & (POSIX path of (selection as alias)) & "\n"
end tell
EOF
)


newName="$1"

oldName_withEnding="${oldPath##*/}"
oldName="${oldName_withEnding%.md}"

oldVaultPath="${oldPath#$vaultPath/}"

newPath="${oldPath/$oldName/$newName}"

newVaultPath="${newPath#$vaultPath/}"


if [ ! -f "$oldPath" ];
then
  echo "Error: File does not exist: $oldPath"
  exit 1
fi


# rename file via Obsidian CLI to change links in Obsidian Notes
echo -e "Renaming file:"$oldName" via Obsidian CLI to update links...\n"
obsidian move file="$oldName" path="$oldVaultPath" to="$newVaultPath"


if [ ! -f "$newPath" ]; then
  echo "Error: Obsidian CLI rename failed."
  exit 1
fi


# reset to old filename via mv - does not affect changed links in Obsidian Notes
echo -e "\nRestoring original filename via mv...\n"
mv "$newPath" "$oldPath"


if [ ! -f "$oldPath" ]; then
  echo "Error: mv restore failed."
  exit 1
fi


# rename file via git mv to keep file history
echo -e "Renaming file via git mv...\n"
git mv "$oldPath" "$newPath"


echo "Rename completed."

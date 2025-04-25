#!/usr/bin/env fish

# Script to rename files from camelCase to kebab-case
# Usage: ./camel-to-kebab.fish [directory]

function camel_to_kebab
    # Get the filename
    set filename (basename $argv[1])
    # Get the directory
    set dir (dirname $argv[1])
    
    # First, insert a dash before each uppercase letter that follows a lowercase letter or digit
    set step1 (echo $filename | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g')
    
    # Then convert the result to lowercase
    set new_name (echo $step1 | tr '[:upper:]' '[:lower:]')
    
    # If the filename changed, rename it
    if test "$filename" != "$new_name"
        echo "Renaming: $filename -> $new_name"
        mv "$dir/$filename" "$dir/$new_name"
    end
end

# Default to current directory if none provided
set target_dir "."
if test (count $argv) -gt 0
    set target_dir $argv[1]
end

echo "Converting camelCase filenames to kebab-case in $target_dir"

# Find all files in the target directory
for file in (find $target_dir -type f -not -path "*/\.*")
    camel_to_kebab $file
end

echo "Conversion complete!"

#!/usr/bin/env fish

# Script to find unused GraphQL fragments
# Usage: ./find-unused-fragments.fish [directory]

# Default to current directory if none provided
set search_dir "."
if test (count $argv) -gt 0
    set search_dir $argv[1]
end

echo "Searching for unused GraphQL fragments in $search_dir..."

# Step 1: Find all fragment definitions and store their names
set fragment_names
for file in (find $search_dir -name "*.graphql" -type f)
    # Extract fragment names using grep and regex
    set -a fragment_names (grep -o -E "^fragment ([A-Za-z0-9_]+)" $file | sed 's/^fragment //')
end

echo "Found "(count $fragment_names)" fragment definitions."

# Step 2 & 3: For each fragment, check if it's used anywhere
set unused_fragments
for fragment in $fragment_names
    # Count occurrences of "...fragmentName" (fragment spread syntax)
    set usage_count 0
    
    for file in (find $search_dir -name "*.graphql" -type f)
        # Count fragment spreads (excluding the fragment's own definition)
        set file_count (grep -c "\\.\\.\\.$fragment" $file)
        set usage_count (math $usage_count + $file_count)
    end
    
    # If usage count is 0, the fragment is unused
    if test $usage_count -eq 0
        set -a unused_fragments $fragment
    end
end

# Display results
if test (count $unused_fragments) -eq 0
    echo "All GraphQL fragments are being used."
else
    echo "Found "(count $unused_fragments)" unused GraphQL fragments:"
    for fragment in $unused_fragments
        echo "  - $fragment"
    end
end

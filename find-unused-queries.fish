#!/usr/bin/env fish

# Script to find unused GraphQL queries
# Usage: ./find-unused-queries.fish [directory]

# Default to current directory if none provided
set search_dir "."
if test (count $argv) -gt 0
    set search_dir $argv[1]
end

echo "Searching for unused GraphQL queries in $search_dir..."

# Step 1: Find all query definitions and store their names
set query_names
for file in (find $search_dir -name "*.graphql" -type f)
    # Extract query names using grep and regex
    set -a query_names (grep -o -E "^query ([A-Za-z0-9_]+)\(" $file | sed -E 's/^query ([A-Za-z0-9_]+)\(/\1/')
end

echo "Found "(count $query_names)" query definitions."

# Step 2 & 3: For each query, check if it's used in TypeScript files
set unused_queries
for query in $query_names
    # Count occurrences of the query name in TypeScript files
    set usage_count 0
    
    # We need to exclude the generated-types file
    for file in (find $search_dir -name "*.ts" -o -name "*.tsx" | grep -v "generated-types/index.ts")
        # Count occurrences of the query name
        set file_count (grep -c "$query" $file)
        set usage_count (math $usage_count + $file_count)
    end
    
    # If usage count is 0, the query is unused
    if test $usage_count -eq 0
        set -a unused_queries $query
    end
end

# Display results
if test (count $unused_queries) -eq 0
    echo "All GraphQL queries are being used in TypeScript files."
else
    echo "Found "(count $unused_queries)" unused GraphQL queries:"
    for query in $unused_queries
        echo "  - $query"
    end
end

#!/usr/bin/env python3
"""
Clean SQL file by removing comment lines that appear between value tuples
in INSERT...VALUES blocks.

Keeps comments that are outside VALUES blocks (like section headers).
"""

import re


def clean_sql_file(input_path, output_path):
    """
    Read SQL file and remove comments between value tuples in INSERT...VALUES blocks.

    Args:
        input_path: Path to input SQL file
        output_path: Path to output cleaned SQL file
    """
    with open(input_path, 'r') as f:
        content = f.read()

    # Split by lines to process
    lines = content.split('\n')

    # Track whether we're inside a VALUES block
    in_values_block = False
    cleaned_lines = []

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Check if this line contains VALUES keyword (start of VALUES block)
        if 'VALUES' in stripped and not stripped.startswith('--'):
            in_values_block = True
            cleaned_lines.append(line)
            continue

        # Check if we're exiting a VALUES block (semicolon ends the statement)
        if in_values_block and stripped.endswith(';'):
            in_values_block = False
            cleaned_lines.append(line)
            continue

        # If we're in a VALUES block and this is a comment line
        if in_values_block and stripped.startswith('--'):
            # Check if this comment is between value tuples
            # It's between tuples if the previous non-blank line ends with '),'
            # and the next non-blank line starts with '('

            prev_line_idx = i - 1
            next_line_idx = i + 1

            # Find previous non-blank, non-comment line
            while prev_line_idx >= 0:
                prev_stripped = lines[prev_line_idx].strip()
                if prev_stripped and not prev_stripped.startswith('--'):
                    break
                prev_line_idx -= 1

            # Find next non-blank, non-comment line
            while next_line_idx < len(lines):
                next_stripped = lines[next_line_idx].strip()
                if next_stripped and not next_stripped.startswith('--'):
                    break
                next_line_idx += 1

            # If previous line ends with ')' or '),' and next starts with '('
            # then this comment is between tuples - remove it
            if prev_line_idx >= 0 and next_line_idx < len(lines):
                prev_stripped = lines[prev_line_idx].strip()
                next_stripped = lines[next_line_idx].strip()

                if (prev_stripped.endswith(')') or prev_stripped.endswith('),')) and \
                   next_stripped.startswith('('):
                    # This is a comment between tuples - skip it (don't add to cleaned_lines)
                    continue

            # Otherwise, keep the comment (it's outside VALUES block context)
            cleaned_lines.append(line)
            continue

        # Keep all other lines
        cleaned_lines.append(line)

    # Write cleaned content
    cleaned_content = '\n'.join(cleaned_lines)
    with open(output_path, 'w') as f:
        f.write(cleaned_content)

    print(f"Cleaned SQL file written to: {output_path}")
    return cleaned_content


def validate_sql_file(file_path):
    """
    Validate that no comment lines exist between value tuples.

    Args:
        file_path: Path to SQL file to validate

    Returns:
        List of problematic lines found, or empty list if valid
    """
    with open(file_path, 'r') as f:
        lines = f.readlines()

    in_values_block = False
    issues = []

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        # Track VALUES blocks
        if 'VALUES' in stripped and not stripped.startswith('--'):
            in_values_block = True
        elif in_values_block and stripped.endswith(';'):
            in_values_block = False

        # Check for comments in VALUES blocks
        if in_values_block and stripped.startswith('--'):
            # Find context
            prev_line = lines[i-2].strip() if i > 1 else ""
            next_line = lines[i].strip() if i < len(lines) else ""

            # Check if it's between tuples
            if (prev_line.endswith(')') or prev_line.endswith('),')) and \
               next_line.startswith('('):
                issues.append({
                    'line_num': i,
                    'content': stripped,
                    'context': f"After: {prev_line[:50]}... Before: {next_line[:50]}..."
                })

    return issues


if __name__ == '__main__':
    input_file = '/sessions/inspiring-zealous-faraday/Fleet-pilot/demo_seed_data.sql'
    output_file = '/sessions/inspiring-zealous-faraday/mnt/outputs/demo_seed_data.sql'

    # Clean the file
    clean_sql_file(input_file, output_file)

    # Validate the output
    print("\nValidating cleaned file...")
    issues = validate_sql_file(output_file)

    if issues:
        print(f"Found {len(issues)} problematic comment lines:")
        for issue in issues:
            print(f"  Line {issue['line_num']}: {issue['content']}")
            print(f"    Context: {issue['context']}")
    else:
        print("Validation passed! No comments found between value tuples.")

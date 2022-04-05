#!/usr/bin/env python
import sys
import re

# take a raw PR name (generally the branch name) and return a name
# that can be used in DNS and other resources for the environment
# max 27 chars
# a-z0-9-_

valid_pr_name_regex = re.compile(r"^[a-z0-9-_]{1,27}$")
allowed_chars = list("abcdefghijklmnopqrstuvwxyz0123456789-_")

if len(sys.argv) != 2:
    print("You must specify a branch name as the first and only command line argument.")
    exit(-1)

raw_pr_name = sys.argv[1]

# Exit early if the branch name already complies with the pattern
if valid_pr_name_regex.fullmatch(raw_pr_name):
    print(raw_pr_name)
    exit(0)

sanitized_pr_name = ""

lower_case_pr_name = raw_pr_name.lower()
for chr in lower_case_pr_name:
    if chr in allowed_chars:
        sanitized_pr_name = sanitized_pr_name + chr
    else:
        if chr in ["/", "*"]:
            sanitized_pr_name = sanitized_pr_name + "-"
        else:
            sanitized_pr_name = sanitized_pr_name + "_"
    if len(sanitized_pr_name) >= 27:
        break

# Confirm the filtered name now matches the valid pattern
if not valid_pr_name_regex.fullmatch(sanitized_pr_name):
    exit(-2)

print(sanitized_pr_name)

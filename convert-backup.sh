#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2002,SC2034,SC1090,SC2154

# Fail fast and fail hard.
set -eo pipefail

INPUT_IN=$1
INPUT_OUT=$2

mkdir -p $INPUT_OUT

while IFS= read -r json; do
    id=$(echo "$json" | jq -cr '.number')
    echo "Converting issue $id"

    title=$(echo "$json" | jq -cr '.title')
    body=$(echo "$json" | jq -cr '.body')
    author=$(echo "$json" | jq -cr '.user.login')
    assignees=$(echo "$json" | jq -cr '.assignees[].login')
    created_at=$(echo "$json" | jq -cr '.created_at')
    milestone=$(echo "$json" | jq -cr '.milestone.title')
    labels=$(echo "$json" | jq -cr '.labels[].name')
    state=$(echo "$json" | jq -cr '.state')
    echo -e "# Issue $id: $title\n\nAuthor **$author** at *$created_at*\n\nAssignees: $assignees\n\nMilestone: $milestone\n\nLabels: $labels\n\nState: **$state**\n\n---\n\n$body\n\n" > $INPUT_OUT/issue-$id.md
    echo -e "## Comments \n\n---">> $INPUT_OUT/issue-$id.md
    while IFS= read -r comment; do
      body=$(echo "$comment" | jq -cr '.body')
      author=$(echo "$comment" | jq -cr '.user.login')
      created_at=$(echo "$comment" | jq -cr '.created_at')
      echo -e "**$author** at *$created_at*\n\n$body\n\n---" >> $INPUT_OUT/issue-$id.md
    done < <(echo "$json" | jq -cr '.comments[]')
done < <(find $INPUT_IN -name "*.json" -exec cat '{}' + | jq "." -cr)

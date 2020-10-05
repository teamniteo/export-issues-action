#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2002,SC2034,SC1090,SC2154

# Fail fast and fail hard.
set -eo pipefail

gh auth login --with-token < <(echo "$GITHUB_TOKEN")

mkdir -p $INPUT_OUT

while IFS= read -r json; do
    id=$(echo "$json" | jq -cr '.number')
    title=$(echo "$json" | jq -cr '.title')
    body=$(echo "$json" | jq -cr '.body')
    author=$(echo "$json" | jq -cr '.author.login')
    createdAt=$(echo "$json" | jq -cr '.createdAt')
    labels=$(echo "$json" | jq -cr '.labels.nodes[].name')
    state=$(echo "$json" | jq -cr '.state')
    echo -e "# Issue $id: $title\n\nAuthor **$author** at *$createdAt*\n\nLabels: $labels\n\nState: **$state**\n\n---\n\n$body\n\n" > issue-$id.md
    echo -e "## Comments \n\n---">> $INPUT_OUT/issue-$id.md
    while IFS= read -r comment; do
      body=$(echo "$comment" | jq -cr '.body')
      author=$(echo "$comment" | jq -cr '.author.login')
      createdAt=$(echo "$comment" | jq -cr '.createdAt')
      echo -e "**$author** at *$createdAt*\n\n$body\n\n---" >> $INPUT_OUT/issue-$id.md
    done < <(echo "$json" | jq -cr '.comments.nodes[]')
done < <(gh api graphql --paginate -F repo=$INPUT_REPO -F org=$INPUT_ORG -f query='query($endCursor: String, $repo: String!, $org: String!) {
  repository(name: $repo, owner: $org) {
    issues(last: 100, after: $endCursor) {
      edges {
        node {
          number
          title
          state
          body
          createdAt
          author {
            login
          }
          state
          labels (last: 100) {
            nodes {
              name
            }
          }
          comments (last: 100) {
            nodes {
              author {
                login
              }
              createdAt
              body
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}' | jq ".data.repository.issues.edges[].node" -cr)

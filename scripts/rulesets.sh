#!/bin/sh

GITHUB_OWNER=$(gh api user/orgs --jq '.[].login')
SENTINEL_REPOSITORY_ID=$(gh api "repos/$GITHUB_OWNER/sentinel-policies" --jq '.id')
TERRAFORM_REPOSITORY_ID=$(gh api "repos/$GITHUB_OWNER/terraform-workflows" --jq '.id')

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/orgs/$GITHUB_OWNER/rulesets" \
  --input - <<< "{
  \"name\": \"azure\",
  \"target\": \"branch\",
  \"enforcement\": \"active\",
  \"conditions\": {
    \"ref_name\": {
      \"include\": [
        \"~DEFAULT_BRANCH\"
      ],
      \"exclude\": []
    },
    \"repository_property\": {
      \"include\": [
        {
          \"name\": \"provider\",
          \"source\": \"custom\",
          \"property_values\": [
            \"azure\"
          ]
        }
      ],
      \"exclude\": []
    }
  },
  \"rules\": [
    {
      \"type\": \"workflows\",
      \"parameters\": {
        \"do_not_enforce_on_create\": true,
        \"workflows\": [
          {
            \"repository_id\": $SENTINEL_REPOSITORY_ID,
            \"path\": \".github/workflows/azure-sentinel.yaml\",
            \"ref\": \"refs/heads/main\"
          }
        ]
      }
    }
  ]
}"

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/orgs/$GITHUB_OWNER/rulesets" \
  --input - <<< "{
  \"name\": \"terraform\",
  \"target\": \"branch\",
  \"enforcement\": \"active\",
  \"conditions\": {
    \"ref_name\": {
      \"include\": [
        \"~DEFAULT_BRANCH\"
      ],
      \"exclude\": []
    },
    \"repository_property\": {
      \"include\": [
        {
          \"name\": \"terraform\",
          \"source\": \"custom\",
          \"property_values\": [
            \"true\"
          ]
        }
      ],
      \"exclude\": []
    }
  },
  \"rules\": [
    {
      \"type\": \"workflows\",
      \"parameters\": {
        \"do_not_enforce_on_create\": true,
        \"workflows\": [
          {
            \"repository_id\": $TERRAFORM_REPOSITORY_ID,
            \"path\": \".github/workflows/terraform-fmt.yaml\",
            \"ref\": \"refs/heads/main\"
          }
        ]
      }
    }
  ]
}"
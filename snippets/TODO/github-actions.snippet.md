# GitHub Actions Snippets

Complete copy-paste artifacts extracted from know-how/github-actions.md.

## CI Workflow Skeleton

```yaml
# .github/workflows/ci.yml
name: CI

on:                                    # triggers
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:                   # manual trigger

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'

      - run: go test ./...
```

## Reusable Workflow

```yaml
# .github/workflows/deploy.yml
on: workflow_call:
  inputs:
    environment:
      type: string
      required: true
    secrets:
      DEPLOY_KEY:
        required: true

jobs:
  deploy:
    steps: ...

# Calling workflow:
jobs:
  deploy-staging:
    uses: ./.github/workflows/deploy.yml
    with:
      environment: staging
    secrets:
      DEPLOY_KEY: ${{ secrets.STAGING_KEY }}
```

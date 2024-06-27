# Deploy to Environments GitHub Action

The **Deploy to Environments** GitHub Action automates the process of creating deployments for all environments in a GitHub repository that match a given regular expression. This action also allows you to exclude environments that match a set of regular expressions.

## Author
ThorLL [<img src="https://skillicons.dev/icons?i=github" alt="GitHub Icon" style="vertical-align: middle; height: 1em;">](https://github.com/ThorLL)

## Usage
To use the Deploy to Environments action, create a [workflow file](https://docs.github.com/en/actions/using-workflows/about-workflows) in your repository (e.g., `github/workflows/deploy.yml`) with the following content:

### Permissions required:
- contents: read
- deployments: write
- actions: read

```yaml
name: Deploy

permissions:
  contents: read
  deployments: write
  actions: read

on:
  release:
    types: [released]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Environments
        uses: ThorLL/deploy-to-environments-gh-action@v1.0.0
        with:
          gh-token: ${{ secrets.GITHUB_TOKEN }}
          ref: 'tags/v1.0.0'
          environments: '.*Testing.*MyActionSystem'
          excluded: '.*Testing-Prod.*;.*Testing-05.*'
```

## Inputs

- `gh-token` (required): GitHub Token used for authentication.
- `ref` (optional, default: `latest_release`): Git ref to be deployed to environments. Defaults to the latest release if not specified.
- `environments` (required): Regular expression that environment names must match.
- `excluded` (optional): Regular expressions separated by `;`. Environments matching any of these will be excluded.

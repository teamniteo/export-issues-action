# WooCart Deploy Action

Sync your GitHub repository with your store on WooCart.com.

## Inputs

### `repo`

**Required** 

### `org`

**Required**

### `out`

**Required**

## Example usage

1. Create a `.github/workflows/export.yml` file in your GitHub repo, if one doesn't exist already.
2. Add the following code to the `export.yml` file.
```yaml
name: Export issues
on:
  schedule:
    # run every 8 hours
    - cron:  '0 0,8,16 * * *'
jobs:
  deploy:
    name: Export issues to S3
    runs-on: ubuntu-latest
    steps:
    - name: Export issues
      uses: niteoweb/export-issues-action@v1
      with:
        repo: ${{ github.repository }}
        org: ${{ github.repository_owner }}
        repo-token: ${{ secrets.GITHUB_TOKEN }}
        out: issues
    - name: Archive production artifacts
      uses: actions/upload-artifact@v2
      with:
        name: issues
        path: "issues/*.md"
```

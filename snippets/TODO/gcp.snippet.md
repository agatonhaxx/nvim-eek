# GCP Snippets

Complete copy-paste artifacts extracted from know-how/gcp.md.

## IAM Policy

```yaml
bindings:
- members:
  - user:alice@example.com
  - serviceAccount:my-sa@project.iam.gserviceaccount.com
  role: roles/storage.objectViewer
- members:
  - group:devs@example.com
  role: roles/compute.admin
```

## IAM Condition

```yaml
condition:
  title: "Office hours only"
  expression: "request.time.getHours('CET') >= 9 && request.time.getHours('CET') < 17"
```

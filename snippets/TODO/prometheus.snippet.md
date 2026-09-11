# Prometheus Snippets

Complete copy-paste artifacts extracted from know-how/prometheus.md.

## Alerting Rule Group

```yaml
groups:
- name: app
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
    for: 5m                              # sustained for 5 minutes
    labels:
      severity: critical
    annotations:
      summary: "High error rate on {{ $labels.job }}"
      description: "5xx rate is {{ $value }} req/s for 5 minutes"
```

## Recording Rule Group

```yaml
groups:
- name: rules
  rules:
  - record: job:http_errors:rate5m
    expr: rate(http_requests_total{status=~"5.."}[5m])
```

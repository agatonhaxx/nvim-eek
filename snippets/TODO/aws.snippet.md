# AWS Snippets

Complete copy-paste artifacts extracted from know-how/aws.md.

## IAM Policy (identity-based)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {"IpAddress": {"aws:SourceIp": "10.0.0.0/8"}}
    }
  ]
}
```

## IAM Trust Policy (role trust)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::123456789012:root"},
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## ECS Task Definition

```json
{
  "family": "myapp",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsExecutionRole",
  "networkMode": "awsvpc",
  "containerDefinitions": [{
    "name": "app",
    "image": "nginx:latest",
    "memory": 512,
    "portMappings": [{"containerPort": 80}]
  }]
}
```

# codedeploy-github-actions

<hr>

Code Deploy GitHub Actions.

<hr>

## Example

```hcl
on: [push]


jobs:
  terraform:
    name: 'Code Deploy'
    runs-on: ubuntu-latest
    steps:
      - name: Code deploy
        uses: plughacker/codedeploy-github-actions@main
        with:
          container_name: ms-test
          container_port: 5000
          application_name: ms-test-app
          deployment_group_name: ms-test-app-dp
          bucket_name: ms-test-bk
          region: us-east-1
```

## Inputs

| Input name     | Description                                         | Required |
|----------------|-----------------------------------------------------|----------|
| container_name           | The name of the ECS container             | Yes      |
| container_port           | The port of the ECS container             | Yes      |
| application_name         | The name of the Code Deploy               | Yes      |
| deployment_group_name    | The name of the Code Deploy group name    | Yes      |
| bucket_name              | The name of the bucket                    |          |
| region                   | AWS Region                                |          |


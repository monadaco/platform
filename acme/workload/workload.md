# Workload Resource

The `Workload` resource can be used to deploy containerized applications to our platform.

## Example

```yaml
apiVersion: acme.com/v1
kind: Workload
metadata:
  name: my-workload
  labels:
    foo: bar
    hello: world
image: hashicorp/http-echo
route: /my-service(/|$)(.*)
rewrite: /$2
replicas: 2
env:
  ECHO_TEXT: bing
port: 5678
```

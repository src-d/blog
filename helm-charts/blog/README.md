# source{d} blog deployment

This is the [Helm](https://helm.sh/) chart to deploy [source{d} blog](https://blog.sourced.tech) in kubernetes.

# Installing the Chart

To manually install the chart, run:

```bash
$ helm install --name <release-name> <path-to-chart> --set \
  image.tag==<label>,\
  ingress.globalStaticIpName=<static-ip>,\
  ingress.hostname=<hostname>
```

These are the mandatory parameters that need to be provided or installation will fail.
Other parameters can be provided too but, if not, a default value will be used.

# Configuration

The most relevant parameters are:

| Parameter                  | Description                                   | Default                     |
| -------------------------- | --------------------------------------------- | --------------------------- |
| image.tag                  | Label to identify image in quay               | none (it's mandatory)       |
| ingress.globalStaticIpName | Static IP (GCE resource's name)               | none (it's mandatory)       |
| ingress.hostname           | Blog's DNS                                    | none (it's mandatory)       |
| replicaCount               | Number of pods                                | `2`                         |
| image.repository           | Path to docker registry                       | `quay.io/srcd/blog`         |

Please refer to [values.yaml](values.yaml) for the full run-down on defaults.

To override any of those default values,
specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided
while installing the chart.
For example,

```bash
$ helm install --name <release-name> -f values.yaml <path-to-chart>
```

> **Tip**: You can use the default [values.yaml](values.yaml)

local domain = 'kzwolenik.com';

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      prometheus+: {
        namespaces+: ['kong-system'],
      },
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: 'https://grafana.' + domain,
            },
          },
        },
      },
    },
    ingress+:: {
      grafana: {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'Ingress',
        metadata: {
          name: $.grafana.service.metadata.name,
          namespace: $.grafana.service.metadata.namespace,
          annotations: {
            // 'konghq.com/plugins': 'ip-restriction-admin-ip,global-file-log',
            'external-dns.alpha.kubernetes.io/hostname': 'grafana.' + domain,
          },
        },
        spec: {
          ingressClassName: 'kong',
          rules: [{
            host: 'grafana.' + domain,
            http: {
              paths: [{
                path: '/',
                pathType: 'ImplementationSpecific',
                backend: {
                  service: {
                    name: $.grafana.service.metadata.name,
                    port: {
                      name: 'http',
                    },
                  },
                },
              }],
            },
          }],
        },
      },
    },
    grafana+:: {
      networkPolicy+: {
        spec+: {
          ingress: [
            super.ingress[0] {
              from+: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'kubernetes.io/metadata.name': 'kong-system',
                    },
                  },
                  podSelector: {
                    matchLabels: {
                      app: 'kong-ingress-gateway',
                    },
                  },
                },
              ],
            },
          ] + super.ingress[1:],
        },
      },
    },

  };

{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule }  //+
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
{ [name + '-ingress']: kp.ingress[name] for name in std.objectFields(kp.ingress) }

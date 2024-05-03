package templates

import "encoding/yaml"

#AppHelm: {
    _composeConfig: {...}
    name: _composeConfig.name
    base: {
        apiVersion: "helm.crossplane.io/v1beta1"
        kind: "Release"
        spec: {
            forProvider: {
                chart: {
                    name: _composeConfig.name
                    repository: string
                    version: string
                }
                set: [...]
                namespace: string | *"kube-system"
            }
            rollbackLimit: int | *3
        }
    }
    patches: [...] | *[{
        fromFieldPath: "spec.id"
        toFieldPath: "metadata.name"
        transforms: [{
            type: "string"
            string: {
                fmt: "%s-" + _composeConfig.name
                type: "Format"
            }
        }]
    }, {
        fromFieldPath: "spec.id"
        toFieldPath: "spec.providerConfigRef.name"
    }]
}

#AppCrossplane: {
    _version: string
    _template: #ReleaseTemplate & {
        _name:            "crossplane"
        _chartName:       "crossplane"
        _chartVersion:    _version
        _chartRepository: "https://charts.crossplane.io/stable"
        _chartURL:        ""
        _namespace:       "crossplane-system"
    }
    #FunctionGoTemplating & {
        step: "app-crossplane"
        input: inline: template: """
        {{ if .observed.composite.resource.spec.parameters.apps.crossplane.enabled }}
        ---
        \( yaml.Marshal(_template) )
        {{ end }}
        """
    }
}

#AppArgoCD: {
    _version: string
    #FunctionGoTemplating & {
        step: "app-argo-cd"
        input: inline: template: """
        {{ if .observed.composite.resource.spec.parameters.apps.argocd.enabled }}
        ---
        apiVersion: helm.crossplane.io/v1beta1
        kind: Release
        metadata:
          name: '{{ $.observed.composite.resource.spec.id }}-app-argo-cd'
          annotations:
            crossplane.io/external-name: argo-cd
            gotemplating.fn.crossplane.io/composition-resource-name: '{{ $.observed.composite.resource.spec.id }}-app-argo-cd'
        spec:
          forProvider:
            chart:
              name: argo-cd
              repository: https://argoproj.github.io/argo-helm
              version: \( _version )
              url: ""
            set: []
            values:
              global:
                domain: {{ $.observed.composite.resource.spec.parameters.apps.argocd.host }}
              configs:
                secret:
                  argocdServerAdminPassword: $2a$10$m3eTlEdRen0nS86c5Zph5u/bDFQMcWZYdG3NVdiyaACCqoxLJaz16
                  argocdServerAdminPasswordMtime: "2021-11-08T15:04:05Z"
                cm:
                  application.resourceTrackingMethod: annotation
                  timeout.reconciliation: 60s
                params:
                  server.insecure: true
              server:
                {{ if $.observed.composite.resource.spec.parameters.apps.traefik.enabled }}
                ingress:
                  enabled: true
                  ingressClassName: traefik
                {{ end }}
                extraArgs:
                  - --insecure
            namespace: argocd
          rollbackLimit: 3
          providerConfigRef:
            name: '{{ $.observed.composite.resource.spec.id }}'
        ---
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        metadata:
          name: {{ $.observed.composite.resource.spec.id }}-app-argo-cd-app
          annotations:
            crossplane.io/external-name: app-argo-cd-app
            gotemplating.fn.crossplane.io/composition-resource-name: {{ $.observed.composite.resource.spec.id }}-app-argo-cd-app
        spec:
          forProvider:
            manifest:
              apiVersion: argoproj.io/v1alpha1
              kind: Application
              metadata:
                name: apps
                namespace: argocd
                finalizers:
                  - resources-finalizer.argocd.argoproj.io
              spec:
                project: default
                source:
                  repoURL: {{ $.observed.composite.resource.spec.parameters.apps.argocd.repoURL }}
                  targetRevision: HEAD
                  path: {{ $.observed.composite.resource.spec.parameters.apps.argocd.sourcePath }}
                destination:
                  server: https://kubernetes.default.svc
                  namespace: {{ $.observed.composite.resource.spec.parameters.apps.argocd.destinationNamespace }}
                syncPolicy:
                  automated:
                    selfHeal: true
                    prune: true
                    allowEmpty: true
          providerConfigRef:
            name: '{{ $.observed.composite.resource.spec.id }}'
        {{ end }}
        """
    }
}

#AppDapr: {
    _version: string
    _template: #ReleaseTemplate & {
        _name:            "dapr"
        _chartName:       "dapr"
        _chartVersion:    _version
        _chartRepository: "https://dapr.github.io/helm-charts/"
        _chartURL:        ""
        _namespace:       "dapr-system"
    }
    #FunctionGoTemplating & {
        step: "app-dapr"
        input: inline: template: """
        {{ if .observed.composite.resource.spec.parameters.apps.dapr.enabled }}
        ---
        \( yaml.Marshal(_template) )
        {{ end }}
        """
    }
}

#AppTraefik: {
    _version: string
    _template: #ReleaseTemplate & {
        _name:            "traefik"
        _chartName:        "traefik"
        _chartVersion:    _version
        _chartRepository: "https://helm.traefik.io/traefik"
        _chartURL:        ""
        _namespace:       "traefik"
    }
    #FunctionGoTemplating & {
        step: "app-traefik"
        input: inline: template: """
        {{ if .observed.composite.resource.spec.parameters.apps.traefik.enabled }}
        ---
        \( yaml.Marshal(_template) )
        {{ end }}
        """
    }
}

#AppDynatrace: {
    _operatorVersion: string
    _dashboardVersion: string
    _apiUrl: "{{ $.observed.composite.resource.spec.parameters.apps.dynatrace.apiUrl }}"
    _id:     "{{ $.observed.composite.resource.spec.id }}"
    _name:   "dynakube"
    _templateDynatrace: #ReleaseTemplate & {
        _name:            "dynatrace-operator"
        _chartName:       "dynatrace-operator"
        _chartVersion:    _operatorVersion
        _chartRepository: "https://raw.githubusercontent.com/Dynatrace/dynatrace-operator/main/config/helm/repos/stable"
        _chartURL:        ""
        _namespace:       "dynatrace"
        _set: [{
            name: "installCRD"
            value: "true"
        }, {
            name: "csidriver.enabled"
            value: "true"
        }]
    }
    _templateDynakube: {
        apiVersion: "kubernetes.crossplane.io/v1alpha2"
        kind:       "Object"
        metadata: {
            name: _id + "-app-" + _name
            annotations: {
                "crossplane.io/external-name": "dynakube"
                "gotemplating.fn.crossplane.io/composition-resource-name": _id + "-app-" + _name
            }
        }
        spec: {
            forProvider: {
                manifest: {
                    apiVersion: "dynatrace.com/v1beta1"
                    kind:       "DynaKube"
                    metadata: {
                        name: _id
                        namespace: "dynatrace"
                        annotations: { "feature.dynatrace.com/k8s-app-enabled": "true" }
                    }
                    spec: {
                        apiUrl: _apiUrl
                        oneAgent: {
                            cloudNativeFullStack: { image: "" }
                        }
                        activeGate: {
                            capabilities: [
                                { "kubernetes-monitoring" },
                                { "routing" },
                                { "metrics-ingest" },
                                { "dynatrace-api" },
                            ]
                            image: ""
                            resources: {
                                requests: {
                                    cpu: "500m"
                                    memory: "512Mi"
                                }
                                limits: {
                                    cpu: "1000m"
                                    memory: "1.5Gi"
                                }
                            }
                        }
                    }
                }
            }
            providerConfigRef: {
                name: _id
            }
        }
    }
    _templateDashboard: #ReleaseTemplate & {
        _name:               "dynatrace-dashboard"
        _chartName:          "kubernetes-cluster"
        _chartVersion:       _dashboardVersion
        _chartRepository:    "https://katharinasick.github.io/crossplane-observability-demo-dynatrace"
        _chartURL:           ""
        _namespace:          "dynatrace"
        _providerConfigName: "{{ $.observed.composite.resource.spec.id }}-local"
        _values: {
            oauthCredentialsSecretName: "{{ $.observed.composite.resource.spec.parameters.apps.dynatrace.oathCredentialsSecretName }}"
            cluster: "{{ $.observed.composite.resource.spec.id }}"
            dashboards: {
                clusterOverview: enabled: true
                crossplaneMetrics: enabled: false
            }
        }
    }
    #FunctionGoTemplating & {
        step: "app-dynatrace"
        input: inline: template: """
        {{ if .observed.composite.resource.spec.parameters.apps.dynatrace.enabled }}
        ---
        \( yaml.Marshal(_templateDynatrace) )
        ---
        \( yaml.Marshal(_templateDynakube) )
        ---
        \( yaml.Marshal(_templateDashboard) )
        {{ end }}
        """
    }
}

#AppOpenFunction: {
    _url: string
    _template: #ReleaseTemplate & {
        _name:            "openfunction"
        _chartName:            "openfunction"
        _chartVersion:    ""
        _chartRepository: ""
        _chartURL:        _url
        _set: [{
            name:  "revisionController.enable"
            value: "true"
        }]
        _namespace: "openfunction"
        // _rollbackLimit: 10
    }
    #FunctionGoTemplating & {
        step: "app-openfunction"
        input: inline: template: """
        {{ if .observed.composite.resource.spec.parameters.apps.openfunction.enabled }}
        ---
        \( yaml.Marshal(_template) )
        {{ end }}
        """
    }
}

#AppExternalSecrets: {
    _version: string
    _template: #ReleaseTemplate & {
        _name:            "external-secrets"
        _chartName:       "external-secrets"
        _chartVersion:    _version
        _chartRepository: "https://charts.external-secrets.io"
        _chartURL:        ""
        _set: [{
            name: "installCRDs"
            value: "true"
        }]
        _namespace: "external-secrets"
    }
    #FunctionGoTemplating & {
        step: "app-external-secrets"
        input: inline: template: """
        {{ if .observed.composite.resource.spec.parameters.apps.externalSecrets.enabled }}
        ---
        \( yaml.Marshal(_template) )
        {{ end }}
        """
    }
}

#AppExternalSecretsSecret: {
    _name: string
    _id:   "{{ $.observed.composite.resource.spec.id }}"
    _fromSecret: "{{ .fromSecret }}"
    _toSecret: "{{ .toSecret }}"
    _toNamespace: "{{ .toNamespace }}"
    _type: "{{ .type }}"
    _template: {
        apiVersion: "kubernetes.crossplane.io/v1alpha2"
        kind: "Object"
        metadata: {
            name: _id + "-secret-" + _toSecret
            annotations: {
                "crossplane.io/external-name": _toSecret
                "gotemplating.fn.crossplane.io/composition-resource-name": _id + "-secret-" + _toSecret
            }
        }
        spec: {
            forProvider: {
                manifest: {
                    apiVersion: "external-secrets.io/v1beta1"
                    kind: "ExternalSecret"
                    metadata: {
                        name: _toSecret
                        namespace: _toNamespace
                    }
                    spec: {
                        refreshInterval: "1h"
                        secretStoreRef: {
                            kind: "ClusterSecretStore"
                            name: _name
                        }
                        target: {
                            name: _toSecret
                            creationPolicy: "Owner"
                            template: type: _type
                        }
                        dataFrom: [{
                            extract: key: _fromSecret
                        }]
                    }
                }
            }
            providerConfigRef: name: _id
        }
    }
    #FunctionGoTemplating & {
        step: "secrets"
        input: inline: template: """
        {{ range .observed.composite.resource.spec.parameters.apps.externalSecrets.secrets }}
        ---
        \( yaml.Marshal(_template) )
        {{ end }}
        """
    }
}

package templates

import (
	crossplane "github.com/crossplane/crossplane/apis/apiextensions/v1"
    runtime "k8s.io/apimachinery/pkg/runtime"
)

#AppHelm: crossplane.#ComposedTemplate & {
    _config:    crossplane.#ComposedTemplate
    name: _config.name
    base: {
        apiVersion: "helm.crossplane.io/v1alpha1"
        kind: "Release"
        spec: {
            forProvider: {
                chart: {
                    name: _config.name
                    repository: string
                    version: string
                }
                namespace: string
            }
            rollbackLimit: 3
        }
    }
    patches: [{
        fromFieldPath: "spec.id"
        toFieldPath: "metadata.name"
        transforms: [{
            type: "string"
            string: {
                fmt: "%s-" + _config.name
            }
        }]
    }, {
        fromFieldPath: "spec.id"
        toFieldPath: "spec.providerConfigRef.name"
    }]
}

#AppTraefik: #AppHelm & { _config:
    name: "traefik"
    base: spec: forProvider: {
        chart: {
            repository: "https://helm.traefik.io/traefik"
            version: string
        }
        namespace: "traefik"
    }
}


#AppCrossplane: #AppHelm & { _config:
    name: "crossplane"
    base: spec: forProvider: {
        chart: {
            repository: "https://charts.crossplane.io/stable"
            version: string
        }
        namespace: "crossplane-system"
    }
}

#AppCrossplaneProvider: crossplane.#ComposedTemplate & {
    _config:    crossplane.#ComposedTemplate
    name: _config.name
    base: {
        apiVersion: "kubernetes.crossplane.io/v1alpha1"
        kind: "Object"
        spec: {
            forProvider: {
                manifest: {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: string | *"Provider"
                    metadata: {
                        name: "crossplane-" + _config.name
                    }
                    spec: {
                        package: string
                        controllerConfigRef: {
                            name: "provider-kubernetes"
                        }
                    }
                }
            }
        }
    }
    patches: [{
        fromFieldPath: "spec.id"
        toFieldPath: "metadata.name"
        transforms: [{
            type: "string"
            string: {
                fmt: "%s-" + _config.name
            }
        }]
    }, {
        fromFieldPath: "spec.id"
        toFieldPath: "spec.providerConfigRef.name"
    }]
}

#AppCrossplaneProviderKubernetes: #AppCrossplaneProvider & { _config:
    name: "kubernetes-provider"
    base: spec: forProvider: manifest: kind: "Provider"
}

#AppCrossplaneProviderHelm: #AppCrossplaneProvider & { _config:
    name: "helm-provider"
}

#AppCrossplaneConfigApp: #AppCrossplaneProvider & { _config:
    name: "app-config"
    base: spec: forProvider: manifest: kind: "Configuration"
}

#AppCrossplaneConfigSql: #AppCrossplaneProvider & { _config:
    name: "sql-config"
    base: spec: forProvider: manifest: kind: "Configuration"
}

#AppObject: crossplane.#ComposedTemplate & {
    _config:    crossplane.#ComposedTemplate
    name: _config.name
    base: {
        apiVersion: "kubernetes.crossplane.io/v1alpha1"
        kind: "Object"
        spec: {
            forProvider: {
                manifest: runtime.#RawExtension
            }
        }
    }
    patches: [{
        fromFieldPath: "spec.id"
        toFieldPath: "metadata.name"
        transforms: [{
            type: "string"
            string: {
                fmt: "%s-" + _config.name
            }
        }]
    }, {
        fromFieldPath: "spec.id"
        toFieldPath: "spec.providerConfigRef.name"
    }]
}

#AppSchemaHeroNs: #AppObject & { _config:
    name: "schemahero-ns"
    base: spec: forProvider: manifest: {
        apiVersion: "v1"
        kind: "Namespace"
        metadata: {
            name: "schemahero-system"
        }
    }
}

#AppSchemaHeroCr: #AppObject & { _config:
    name: "schemahero-cr"
    base: spec: forProvider: manifest: {
        apiVersion: "rbac.authorization.k8s.io/v1"
        kind:       "ClusterRole"
        metadata: {
            creationTimestamp: null
            name:              "schemahero-role"
        }
        rules: [{
            apiGroups: [
                "apps",
            ]
            resources: [
                "deployments",
                "statefulsets",
            ]
            verbs: [
                "get",
                "list",
                "watch",
                "create",
                "update",
                "patch",
                "delete",
            ]
        }, {
            apiGroups: [
                "apps",
            ]
            resources: [
                "deployments/status",
                "statefulset/status",
            ]
            verbs: [
                "get",
                "update",
                "patch",
            ]
        }, {
            apiGroups: [
                "",
            ]
            resources: [
                "pods",
            ]
            verbs: [
                "get",
                "list",
                "watch",
                "create",
                "update",
                "patch",
                "delete",
            ]
        }, {
            apiGroups: [
                "",
            ]
            resources: [
                "pods/log",
            ]
            verbs: [
                "get",
            ]
        }, {
            apiGroups: [
                "",
            ]
            resources: [
                "secrets",
            ]
            verbs: [
                "get",
                "list",
                "watch",
                "create",
                "update",
                "patch",
                "delete",
            ]
        }, {
            apiGroups: [
                "",
            ]
            resources: [
                "serviceaccounts",
            ]
            verbs: [
                "get",
                "list",
                "create",
                "update",
                "delete",
                "watch",
            ]
        }, {
            apiGroups: [
                "rbac.authorization.k8s.io",
            ]
            resources: [
                "roles",
                "rolebindings",
            ]
            verbs: [
                "get",
                "list",
                "create",
                "update",
                "delete",
                "watch",
            ]
        }, {
            apiGroups: [
                "admissionregistration.k8s.io",
            ]
            resources: [
                "mutatingwebhookconfigurations",
                "validatingwebhookconfigurations",
            ]
            verbs: [
                "get",
                "list",
                "watch",
                "create",
                "update",
                "patch",
                "delete",
            ]
        }, {
            apiGroups: [
                "databases.schemahero.io",
            ]
            resources: [
                "databases",
            ]
            verbs: [
                "get",
                "list",
                "watch",
                "create",
                "update",
                "patch",
                "delete",
            ]
        }, {
            apiGroups: [
                "databases.schemahero.io",
            ]
            resources: [
                "databases/status",
            ]
            verbs: [
                "get",
                "update",
                "patch",
            ]
        }, {
            apiGroups: [
                "schemas.schemahero.io",
            ]
            resources: [
                "migrations",
            ]
            verbs: [
                "get",
                "list",
                "watch",
                "create",
                "update",
                "patch",
                "delete",
            ]
        }, {
            apiGroups: [
                "schemas.schemahero.io",
            ]
            resources: [
                "migrations/status",
            ]
            verbs: [
                "get",
                "update",
                "patch",
            ]
        }, {
            apiGroups: [
                "schemas.schemahero.io",
            ]
            resources: [
                "tables",
            ]
            verbs: [
                "get",
                "list",
                "watch",
                "create",
                "update",
                "patch",
                "delete",
            ]
        }, {
            apiGroups: [
                "schemas.schemahero.io",
            ]
            resources: [
                "tables/status",
            ]
            verbs: [
                "get",
                "update",
                "patch",
            ]
        }]
    }
}

#AppSchemaHeroCrb: #AppObject & { _config:
    name: "schemahero-crb"
    base: spec: forProvider: manifest: {
        apiVersion: "rbac.authorization.k8s.io/v1"
        kind:       "ClusterRoleBinding"
        metadata: {
            creationTimestamp: null
            name:              "schemahero-rolebinding"
        }
        roleRef: {
            apiGroup: "rbac.authorization.k8s.io"
            kind:     "ClusterRole"
            name:     "schemahero-role"
        }
        subjects: [{
            kind:      "ServiceAccount"
            name:      "default"
            namespace: "schemahero-system"
        }]
    }
}

#AppSchemaHeroService: #AppObject & { _config:
    name: "schemahero-service"
    base: spec: forProvider: manifest: {
        apiVersion: "v1"
        kind:       "Service"
        metadata: {
            creationTimestamp: null
            name:              "controller-manager-service"
            namespace:         "schemahero-system"
        }
        spec: {
            ports: [{
                port:       443
                targetPort: 9876
            }]
            selector: "control-plane": "schemahero"
        }
        status: loadBalancer: {}
    }
}

#AppSchemaHeroSecret: #AppObject & { _config:
    name: "schemahero-secret"
    base: spec: forProvider: manifest: {
        apiVersion: "v1"
        kind:       "Secret"
        metadata: {
            creationTimestamp: null
            name:              "webhook-server-secret"
            namespace:         "schemahero-system"
        }
    }
}

#AppSchemaHeroSts: #AppObject & { _config:
    name: "schemahero-sts"
    base: spec: forProvider: manifest: {
        apiVersion: "apps/v1"
        kind:       "StatefulSet"
        metadata: {
            creationTimestamp: null
            labels: "control-plane": "schemahero"
            name:      "schemahero"
            namespace: "schemahero-system"
        }
        spec: {
            selector: matchLabels: "control-plane": "schemahero"
            serviceName: ""
            template: {
                metadata: {
                    creationTimestamp: null
                    labels: "control-plane": "schemahero"
                }
                spec: {
                    affinity: nodeAffinity: requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
                        matchExpressions: [{
                            key:      "kubernetes.io/os"
                            operator: "In"
                            values: [
                                "linux",
                            ]
                        }, {
                            key:      "kubernetes.io/arch"
                            operator: "In"
                            values: [
                                "amd64",
                            ]
                        }]
                    }]
                    containers: [{
                        command: [
                            "/manager",
                            "run",
                            "--enable-database-controller",
                        ]
                        env: [{
                            name: "POD_NAMESPACE"
                            valueFrom: fieldRef: fieldPath: "metadata.namespace"
                        }, {
                            name:  "SECRET_NAME"
                            value: "webhook-server-secret"
                        }]
                        image:           "schemahero/schemahero-manager:0.13.8"
                        imagePullPolicy: "Always"
                        name:            "manager"
                        ports: [{
                            containerPort: 9876
                            name:          "webhook-server"
                            protocol:      "TCP"
                        }]
                        resources: {
                            limits: {
                                cpu:    "1"
                                memory: "150Mi"
                            }
                            requests: {
                                cpu:    "100m"
                                memory: "50Mi"
                            }
                        }
                        volumeMounts: [{
                            mountPath: "/tmp/cert"
                            name:      "cert"
                            readOnly:  true
                        }]
                    }]
                    terminationGracePeriodSeconds: 10
                    volumes: [{
                        name: "cert"
                        secret: {
                            defaultMode: 420
                            secretName:  "webhook-server-secret"
                        }
                    }]
                }
            }
            updateStrategy: {}
        }
        status: {
            availableReplicas: 0
            replicas:          0
        }
    }
}

#AppSchemaHeroCrdDb: #AppObject & { _config:
    name: "schemahero-crd-db"
    base: spec: forProvider: manifest: {
        apiVersion: "apiextensions.k8s.io/v1"
        kind:       "CustomResourceDefinition"
        metadata: {
            annotations: "controller-gen.kubebuilder.io/version": "v0.7.0"
            creationTimestamp: null
            name:              "databases.databases.schemahero.io"
        }
        spec: {
            group: "databases.schemahero.io"
            names: {
                kind:     "Database"
                listKind: "DatabaseList"
                plural:   "databases"
                singular: "database"
            }
            scope: "Namespaced"
            versions: [{
                additionalPrinterColumns: [{
                    jsonPath: ".metadata.namespace"
                    name:     "Namespace"
                    priority: 1
                    type:     "string"
                }, {
                    jsonPath: ".spec.immediateDeploy"
                    name:     "Deploy Immediately"
                    priority: 1
                    type:     "boolean"
                }, {
                    jsonPath: ".metadata.creationTimestamp"
                    name:     "Age"
                    type:     "date"
                }]
                name: "v1alpha4"
                schema: openAPIV3Schema: {
                    description: "Database is the Schema for the databases API"
                    properties: {
                        apiVersion: {
                            description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"

                            type: "string"
                        }
                        kind: {
                            description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"

                            type: "string"
                        }
                        metadata: type: "object"
                        spec: {
                            properties: {
                                connection: {
                                    description: "DatabaseConnection defines connection parameters for the database driver"

                                    properties: {
                                        cassandra: {
                                            properties: {
                                                hosts: {
                                                    items: type: "string"
                                                    type: "array"
                                                }
                                                keyspace: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                password: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                username: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                            }
                                            required: [
                                                "hosts",
                                                "keyspace",
                                            ]
                                            type: "object"
                                        }
                                        cockroachdb: {
                                            properties: {
                                                dbname: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                host: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                password: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                port: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                schema: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                sslmode: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                uri: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                user: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                            }
                                            type: "object"
                                        }
                                        mysql: {
                                            properties: {
                                                collation: type: "string"
                                                dbname: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                defaultCharset: type: "string"
                                                disableTLS: type: "boolean"
                                                host: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                password: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                port: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                uri: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                user: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                            }
                                            type: "object"
                                        }
                                        postgres: {
                                            properties: {
                                                dbname: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                host: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                password: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                port: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                schema: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                sslmode: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                uri: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                                user: {
                                                    properties: {
                                                        value: type: "string"
                                                        valueFrom: {
                                                            properties: {
                                                                secretKeyRef: {
                                                                    properties: {
                                                                        key: type: "string"
                                                                        name: type: "string"
                                                                    }
                                                                    required: [
                                                                        "key",
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                ssm: {
                                                                    properties: {
                                                                        accessKeyId: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        name: type: "string"
                                                                        region: type: "string"
                                                                        secretAccessKey: {
                                                                            properties: {
                                                                                value: type: "string"
                                                                                valueFrom: {
                                                                                    properties: secretKeyRef: {
                                                                                        properties: {
                                                                                            key: type: "string"
                                                                                            name: type: "string"
                                                                                        }
                                                                                        required: [
                                                                                            "key",
                                                                                            "name",
                                                                                        ]
                                                                                        type: "object"
                                                                                    }
                                                                                    type: "object"
                                                                                }
                                                                            }
                                                                            required: [
                                                                                "value",
                                                                            ]
                                                                            type: "object"
                                                                        }
                                                                        withDecryption: type: "boolean"
                                                                    }
                                                                    required: [
                                                                        "name",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                                vault: {
                                                                    properties: {
                                                                        agentInject: type: "boolean"
                                                                        connectionTemplate: type: "string"
                                                                        endpoint: type: "string"
                                                                        kubernetesAuthEndpoint: type: "string"
                                                                        role: type: "string"
                                                                        secret: type: "string"
                                                                        serviceAccount: type: "string"
                                                                        serviceAccountNamespace: type: "string"
                                                                    }
                                                                    required: [
                                                                        "role",
                                                                        "secret",
                                                                    ]
                                                                    type: "object"
                                                                }
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    type: "object"
                                                }
                                            }
                                            type: "object"
                                        }
                                        sqlite: {
                                            properties: dsn: type: "string"
                                            required: [
                                                "dsn",
                                            ]
                                            type: "object"
                                        }
                                    }
                                    type: "object"
                                }
                                deploySeedData: type: "boolean"
                                enableShellCommand: type: "boolean"
                                immediateDeploy: {
                                    default: false
                                    type:    "boolean"
                                }
                                schemahero: {
                                    properties: {
                                        image: type: "string"
                                        nodeSelector: {
                                            additionalProperties: type: "string"
                                            type: "object"
                                        }
                                    }
                                    type: "object"
                                }
                                template: {
                                    properties: metadata: {
                                        properties: {
                                            annotations: {
                                                additionalProperties: type: "string"
                                                type: "object"
                                            }
                                            finalizers: {
                                                items: type: "string"
                                                type: "array"
                                            }
                                            labels: {
                                                additionalProperties: type: "string"
                                                type: "object"
                                            }
                                            name: type: "string"
                                            namespace: type: "string"
                                        }
                                        type: "object"
                                    }
                                    type: "object"
                                }
                            }
                            type: "object"
                        }
                        status: {
                            description: "DatabaseStatus defines the observed state of Database"
                            properties: {
                                isConnected: type: "boolean"
                                lastPing: type: "string"
                            }
                            required: [
                                "isConnected",
                                "lastPing",
                            ]
                            type: "object"
                        }
                    }
                    required: [
                        "spec",
                    ]
                    type: "object"
                }
                served:  true
                storage: true
                subresources: status: {}
            }]
        }
        status: {
            acceptedNames: {
                kind:   ""
                plural: ""
            }
            conditions: []
            storedVersions: []
        }
    }
}

#AppSchemaHeroCrdTable: #AppObject & { _config:
    name: "schemahero-crd-table"
    base: spec: forProvider: manifest: {
        apiVersion: "apiextensions.k8s.io/v1"
        kind:       "CustomResourceDefinition"
        metadata: {
            annotations: "controller-gen.kubebuilder.io/version": "v0.7.0"
            creationTimestamp: null
            name:              "tables.schemas.schemahero.io"
        }
        spec: {
            group: "schemas.schemahero.io"
            names: {
                kind:     "Table"
                listKind: "TableList"
                plural:   "tables"
                singular: "table"
            }
            scope: "Namespaced"
            versions: [{
                additionalPrinterColumns: [{
                    jsonPath: ".metadata.namespace"
                    name:     "Namespace"
                    priority: 1
                    type:     "string"
                }, {
                    jsonPath: ".spec.name"
                    name:     "Table"
                    type:     "string"
                }, {
                    jsonPath: ".spec.database"
                    name:     "Database"
                    type:     "string"
                }, {
                    jsonPath: ".metadata.creationTimestamp"
                    name:     "Age"
                    type:     "date"
                }]
                name: "v1alpha4"
                schema: openAPIV3Schema: {
                    description: "Table is the Schema for the tables API"
                    properties: {
                        apiVersion: {
                            description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"

                            type: "string"
                        }
                        kind: {
                            description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"

                            type: "string"
                        }
                        metadata: type: "object"
                        spec: {
                            description: "TableSpec defines the desired state of Table"
                            properties: {
                                database: type: "string"
                                name: type: "string"
                                requires: {
                                    items: type: "string"
                                    type: "array"
                                }
                                schema: {
                                    properties: {
                                        cassandra: {
                                            properties: {
                                                clusteringOrder: {
                                                    properties: {
                                                        column: type: "string"
                                                        isDescending: type: "boolean"
                                                    }
                                                    required: [
                                                        "column",
                                                    ]
                                                    type: "object"
                                                }
                                                columns: {
                                                    items: {
                                                        properties: {
                                                            isStatic: type: "boolean"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "name",
                                                            "type",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                isDeleted: type: "boolean"
                                                primaryKey: {
                                                    items: {
                                                        items: type: "string"
                                                        type: "array"
                                                    }
                                                    type: "array"
                                                }
                                                properties: {
                                                    properties: {
                                                        bloomFilterFPChance: type: "string"
                                                        caching: {
                                                            additionalProperties: type: "string"
                                                            type: "object"
                                                        }
                                                        comment: type: "string"
                                                        compaction: {
                                                            additionalProperties: type: "string"
                                                            type: "object"
                                                        }
                                                        compression: {
                                                            additionalProperties: type: "string"
                                                            type: "object"
                                                        }
                                                        crcCheckChance: type: "string"
                                                        dcLocalReadRepairChance: type: "string"
                                                        defaultTTL: type: "integer"
                                                        gcGraceSeconds: type: "integer"
                                                        maxIndexInterval: type: "integer"
                                                        memtableFlushPeriodMs: type: "integer"
                                                        minIndexInterval: type: "integer"
                                                        readRepairChance: type: "string"
                                                        speculativeRetry: type: "string"
                                                    }
                                                    type: "object"
                                                }
                                            }
                                            type: "object"
                                        }
                                        cockroachdb: {
                                            properties: {
                                                columns: {
                                                    items: {
                                                        properties: {
                                                            attributes: {
                                                                properties: autoIncrement: type: "boolean"
                                                                type: "object"
                                                            }
                                                            constraints: {
                                                                properties: notNull: type: "boolean"
                                                                type: "object"
                                                            }
                                                            default: type: "string"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "name",
                                                            "type",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                foreignKeys: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            name: type: "string"
                                                            onDelete: type: "string"
                                                            references: {
                                                                properties: {
                                                                    columns: {
                                                                        items: type: "string"
                                                                        type: "array"
                                                                    }
                                                                    table: type: "string"
                                                                }
                                                                required: [
                                                                    "columns",
                                                                    "table",
                                                                ]
                                                                type: "object"
                                                            }
                                                        }
                                                        required: [
                                                            "columns",
                                                            "references",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                indexes: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            isUnique: type: "boolean"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "columns",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                isDeleted: type: "boolean"
                                                "json:triggers": {
                                                    items: {
                                                        properties: {
                                                            arguments: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            condition: type: "string"
                                                            constraintTrigger: type: "boolean"
                                                            events: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            executeProcedure: type: "string"
                                                            forEachRun: type: "boolean"
                                                            forEachStatement: type: "boolean"
                                                            name: type: "string"
                                                        }
                                                        required: [
                                                            "events",
                                                            "executeProcedure",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                primaryKey: {
                                                    items: type: "string"
                                                    type: "array"
                                                }
                                            }
                                            type: "object"
                                        }
                                        mysql: {
                                            properties: {
                                                collation: type: "string"
                                                columns: {
                                                    items: {
                                                        properties: {
                                                            attributes: {
                                                                properties: autoIncrement: type: "boolean"
                                                                type: "object"
                                                            }
                                                            charset: type: "string"
                                                            collation: type: "string"
                                                            constraints: {
                                                                properties: notNull: type: "boolean"
                                                                type: "object"
                                                            }
                                                            default: type: "string"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "name",
                                                            "type",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                defaultCharset: type: "string"
                                                foreignKeys: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            name: type: "string"
                                                            onDelete: type: "string"
                                                            references: {
                                                                properties: {
                                                                    columns: {
                                                                        items: type: "string"
                                                                        type: "array"
                                                                    }
                                                                    table: type: "string"
                                                                }
                                                                required: [
                                                                    "columns",
                                                                    "table",
                                                                ]
                                                                type: "object"
                                                            }
                                                        }
                                                        required: [
                                                            "columns",
                                                            "references",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                indexes: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            isUnique: type: "boolean"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "columns",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                isDeleted: type: "boolean"
                                                primaryKey: {
                                                    items: type: "string"
                                                    type: "array"
                                                }
                                            }
                                            type: "object"
                                        }
                                        postgres: {
                                            properties: {
                                                columns: {
                                                    items: {
                                                        properties: {
                                                            attributes: {
                                                                properties: autoIncrement: type: "boolean"
                                                                type: "object"
                                                            }
                                                            constraints: {
                                                                properties: notNull: type: "boolean"
                                                                type: "object"
                                                            }
                                                            default: type: "string"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "name",
                                                            "type",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                foreignKeys: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            name: type: "string"
                                                            onDelete: type: "string"
                                                            references: {
                                                                properties: {
                                                                    columns: {
                                                                        items: type: "string"
                                                                        type: "array"
                                                                    }
                                                                    table: type: "string"
                                                                }
                                                                required: [
                                                                    "columns",
                                                                    "table",
                                                                ]
                                                                type: "object"
                                                            }
                                                        }
                                                        required: [
                                                            "columns",
                                                            "references",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                indexes: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            isUnique: type: "boolean"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "columns",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                isDeleted: type: "boolean"
                                                "json:triggers": {
                                                    items: {
                                                        properties: {
                                                            arguments: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            condition: type: "string"
                                                            constraintTrigger: type: "boolean"
                                                            events: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            executeProcedure: type: "string"
                                                            forEachRun: type: "boolean"
                                                            forEachStatement: type: "boolean"
                                                            name: type: "string"
                                                        }
                                                        required: [
                                                            "events",
                                                            "executeProcedure",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                primaryKey: {
                                                    items: type: "string"
                                                    type: "array"
                                                }
                                            }
                                            type: "object"
                                        }
                                        sqlite: {
                                            properties: {
                                                columns: {
                                                    items: {
                                                        properties: {
                                                            attributes: {
                                                                properties: autoIncrement: type: "boolean"
                                                                type: "object"
                                                            }
                                                            constraints: {
                                                                properties: notNull: type: "boolean"
                                                                type: "object"
                                                            }
                                                            default: type: "string"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "name",
                                                            "type",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                foreignKeys: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            name: type: "string"
                                                            onDelete: type: "string"
                                                            references: {
                                                                properties: {
                                                                    columns: {
                                                                        items: type: "string"
                                                                        type: "array"
                                                                    }
                                                                    table: type: "string"
                                                                }
                                                                required: [
                                                                    "columns",
                                                                    "table",
                                                                ]
                                                                type: "object"
                                                            }
                                                        }
                                                        required: [
                                                            "columns",
                                                            "references",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                indexes: {
                                                    items: {
                                                        properties: {
                                                            columns: {
                                                                items: type: "string"
                                                                type: "array"
                                                            }
                                                            isUnique: type: "boolean"
                                                            name: type: "string"
                                                            type: type: "string"
                                                        }
                                                        required: [
                                                            "columns",
                                                        ]
                                                        type: "object"
                                                    }
                                                    type: "array"
                                                }
                                                isDeleted: type: "boolean"
                                                primaryKey: {
                                                    items: type: "string"
                                                    type: "array"
                                                }
                                            }
                                            type: "object"
                                        }
                                    }
                                    type: "object"
                                }
                                seedData: {
                                    properties: rows: {
                                        items: {
                                            properties: columns: {
                                                items: {
                                                    properties: {
                                                        column: type: "string"
                                                        value: {
                                                            properties: {
                                                                int: type: "integer"
                                                                str: type: "string"
                                                            }
                                                            type: "object"
                                                        }
                                                    }
                                                    required: [
                                                        "column",
                                                        "value",
                                                    ]
                                                    type: "object"
                                                }
                                                type: "array"
                                            }
                                            required: [
                                                "columns",
                                            ]
                                            type: "object"
                                        }
                                        type: "array"
                                    }
                                    required: [
                                        "rows",
                                    ]
                                    type: "object"
                                }
                            }
                            required: [
                                "database",
                                "name",
                            ]
                            type: "object"
                        }
                        status: {
                            description: "TableStatus defines the observed state of Table"
                            properties: lastPlannedTableSpecSHA: {
                                description: "We store the SHA of the table spec from the last time we executed a plan to make startup less noisy by skipping re-planning objects that have been planned we cannot use the resourceVersion or generation fields because updating them would cause the object to be modified again"

                                type: "string"
                            }
                            type: "object"
                        }
                    }
                    type: "object"
                }
                served:  true
                storage: true
                subresources: {}
            }]
        }
        status: {
            acceptedNames: {
                kind:   ""
                plural: ""
            }
            conditions: []
            storedVersions: []
        }
    }
}

#AppSchemaHeroCrdMigration: #AppObject & { _config:
    name: "schemahero-crd-migration"
    base: spec: forProvider: manifest: {
        apiVersion: "apiextensions.k8s.io/v1"
        kind:       "CustomResourceDefinition"
        metadata: {
            annotations: "controller-gen.kubebuilder.io/version": "v0.7.0"
            creationTimestamp: null
            name:              "migrations.schemas.schemahero.io"
        }
        spec: {
            group: "schemas.schemahero.io"
            names: {
                kind:     "Migration"
                listKind: "MigrationList"
                plural:   "migrations"
                singular: "migration"
            }
            scope: "Namespaced"
            versions: [{
                additionalPrinterColumns: [{
                    jsonPath: ".spec.databaseName"
                    name:     "Database"
                    type:     "string"
                }, {
                    jsonPath: ".spec.tableName"
                    name:     "Table"
                    type:     "string"
                }, {
                    jsonPath: ".metadata.namespace"
                    name:     "Namespace"
                    priority: 1
                    type:     "string"
                }, {
                    jsonPath: ".status.phase"
                    name:     "Phase"
                    type:     "string"
                }, {
                    jsonPath: ".metadata.creationTimestamp"
                    name:     "Age"
                    type:     "date"
                }]
                name: "v1alpha4"
                schema: openAPIV3Schema: {
                    description: "Migration is the Schema for the migrations API"
                    properties: {
                        apiVersion: {
                            description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"

                            type: "string"
                        }
                        kind: {
                            description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"

                            type: "string"
                        }
                        metadata: type: "object"
                        spec: {
                            description: "MigrationSpec defines the desired state of Migration"
                            properties: {
                                databaseName: type: "string"
                                editedDDL: type: "string"
                                generatedDDL: type: "string"
                                tableName: type: "string"
                                tableNamespace: type: "string"
                            }
                            required: [
                                "tableName",
                                "tableNamespace",
                            ]
                            type: "object"
                        }
                        status: {
                            description: "MigrationStatus defines the observed state of Migration"
                            properties: {
                                approvedAt: {
                                    format: "int64"
                                    type:   "integer"
                                }
                                executedAt: {
                                    format: "int64"
                                    type:   "integer"
                                }
                                invalidatedAt: {
                                    description: "InvalidatedAt is the unix nano timestamp when this plan was determined to be invalid or outdated"

                                    format: "int64"
                                    type:   "integer"
                                }
                                phase: {
                                    enum: [
                                        "PLANNED",
                                        "APPROVED",
                                        "EXECUTED",
                                        "INVALID",
                                    ]
                                    type: "string"
                                }
                                plannedAt: {
                                    description: "PlannedAt is the unix nano timestamp when the plan was generated"

                                    format: "int64"
                                    type:   "integer"
                                }
                                rejectedAt: {
                                    format: "int64"
                                    type:   "integer"
                                }
                            }
                            type: "object"
                        }
                    }
                    type: "object"
                }
                served:  true
                storage: true
                subresources: {}
            }]
        }
        status: {
            acceptedNames: {
                kind:   ""
                plural: ""
            }
            conditions: []
            storedVersions: []
        }
    }
}
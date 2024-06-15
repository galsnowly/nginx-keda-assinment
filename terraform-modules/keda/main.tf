provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "carbynee"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "aws_sqs_queue" "keda_queue" {
  name = "keda-sqs-queue"
}

resource "kubernetes_namespace" "keda" {
  metadata {
    name = "keda"
  }
}

resource "helm_release" "keda" {
  name       = "keda"
  namespace  = kubernetes_namespace.keda.metadata[0].name
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = "2.14.0"

  values = [
    <<EOF
additionalLabels: {}
EOF
  ]

  depends_on = [kubernetes_namespace.keda]
}
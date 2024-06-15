provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "carbynee"
}

resource "kubernetes_secret" "aws_credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = var.keda_namespace
  }

  data = {
    awsAccessKeyID     = var.aws_access_key_id
    awsSecretAccessKey = var.aws_secret_access_key
  }

  type = "Opaque"
}

resource "kubernetes_manifest" "keda_trigger_authentication" {
  manifest = yamldecode(templatefile("${path.module}/trigger_authentication.yaml.tpl", {
    namespace = var.keda_namespace
  }))
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = var.keda_namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = var.keda_namespace
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_manifest" "keda_scaledobject" {
  manifest = yamldecode(templatefile("${path.module}/keda_scaledobject.yaml.tpl", {
    namespace    = var.keda_namespace,
    queue_url    = var.keda_queue_url,
    aws_region   = var.aws_region
  }))

  depends_on = [
    kubernetes_deployment.nginx,
    kubernetes_manifest.keda_trigger_authentication
  ]
}

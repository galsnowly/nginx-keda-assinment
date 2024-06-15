output "namespace" {
  value = kubernetes_namespace.keda.metadata[0].name
}

output "queue_url" {
  value = aws_sqs_queue.keda_queue.url
}
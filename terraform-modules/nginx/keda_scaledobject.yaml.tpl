apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: nginx-sqs-scaledobject
  namespace: ${namespace}
spec:
  scaleTargetRef:
    name: nginx-deployment
  minReplicaCount: 1
  maxReplicaCount: 10
  triggers:
  - type: aws-sqs-queue
    metadata:
      queueURL: ${queue_url}
      queueLength: "10"
      awsRegion: ${aws_region}
    authenticationRef:
      name: aws-sqs-trigger-auth
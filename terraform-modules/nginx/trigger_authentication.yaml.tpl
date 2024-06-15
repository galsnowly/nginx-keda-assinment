apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: aws-sqs-trigger-auth
  namespace: ${namespace}
spec:
  secretTargetRef:
    - parameter: awsAccessKeyID
      name: aws-credentials
      key: awsAccessKeyID
    - parameter: awsSecretAccessKey
      name: aws-credentials
      key: awsSecretAccessKey
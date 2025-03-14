# Setup initial Vault configuration

1. Apply prerequisites:
   ```console
   kubectl apply -f preq.yaml
   ```
2. Generate short lived vault token
   ```console
   vault token create -ttl="2m"
   ```
3. Run the job:
   ```console
    export TF_VAR_token="<token value>"
   envsubst < job.yaml | kubectl apply -f -
   ```
4. Review logs:
   ```console
   kubectl logs job/terraform-apply
   ```

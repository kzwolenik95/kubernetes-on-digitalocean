# Setup initial Vault configuration

1. Generate short lived vault token
   ```console
   vault token create -ttl="2m"
   ```
2. Run the job:
   ```console
    export TF_VAR_token="<token value>"
   envsubst < job.yaml | kubectl apply -f -
   ```

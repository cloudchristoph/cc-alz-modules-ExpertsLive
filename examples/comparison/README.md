# Comparison of the different methods to deploy a Storage Account

The `storage_accounts.bicep` script will deploy two Storage Accounts using the default resource provider and using the Azure Verified Module.
This will allow the comparison of the end result of both methods.

After deployment, I've exported the ARM template of the deployed resources and compared them. There are a few differences between the two methods, but I've only written down the important ones.

## Results

| Property                 | Default Resource Provider | Azure Verified Module |
| ------------------------ | ------------------------- | --------------------- |
| Redundancy               | _has to be set as param_  | Standard_GRS          |
| Minimum TLS version      | 1.0                       | 1.2                   |
| Network ACL              | Default Allow             | Default Deny          |
| Infra Encryption         | Disabled                  | Enabled               |
| Cross Tenant Replication | Disabled                  | Enabled               |

## Last check

The last check was done on 2024-06-04. The results might have changed since then.

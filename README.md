# README

## How-To

1. Fork this repo.
2. Create container apps enviroment.
3. Set some environment variables.
4. Set up github action.
5. Deploy application to container apps

## TODO

- The build variable is not the correct git hash. For now, I'm using "--iso-8601" instead.
- In bicep deploy, It is divided into build and deploy, but it doesn't make much sense to clone both.
- Avoid PAT. I'm using PAT to access the GitHub Package from Container Apps. disappointing.
- Use git tags for revision suffix.
- fix az cli 

## memo 5/30

```sh
Run azure/arm-deploy@v1
  with:
    resourceGroupName: ***
    template: ./deploy/main.bicep
    parameters: containerAppName=*** environmentName=*** containerImage=***/***/aca-go01/aca-go01-8436ce52858d5d3cf8603cd48ebbd608@sha256:d1a93d0f68fc8153b3c45ef90eaad112211d4639965800a9db7f0e8472c5ae2a containerPort=8080 containerRegistry=*** containerRegistryUsername=*** containerRegistryPassword=*** revisionSuffix=v1.0.6
    failOnStdErr: false
```

```
$ az containerapp revision list  -n goweb01 -g  omi31-rg -o table
CreatedTime                Active    Replicas    TrafficWeight    HealthState    ProvisioningState    Name
-------------------------  --------  ----------  ---------------  -------------  -------------------  ----------------

... snip ...

2022-05-29T23:02:44+00:00  False     0           0                Healthy        Provisioned          goweb01--b4bb8b7
2022-05-30T00:11:27+00:00  True      0           100              Healthy        Provisioned          goweb01--db42973

# request aca
$ make curl-apps
curl -L $(az containerapp show -n goweb01 -g  omi31-rg --query properties.configuration.ingress.fqdn -o tsv)
Hello world with GitHub Action !! "db42973"%
```
REPO_USER		?= <OVERWRITE HERE>
REPOSITORY_NAME		?= <OVERWRITE HERE>
RESOURCE_GROUP		?= <OVERWRITE HERE>
CONTAINERAPPS_NAME	?= <OVERWRITE HERE>
ENVIRONMENT_NAME	?= <OVERWRITE HERE>
SUBSCRIPTION_ID		=  $(shell  az account show --query 'id' -o tsv)
TENANT_ID		=  $(shell  az account show --query 'tenantId' -o tsv)

BRANCH_NAME 		?= main
SP_NAME			?= $(RESOURCE_GROUP)-sp



export KO_DOCKER_REPO=ghcr.io/$(REPO_USER)/aca-goaca01
export VERSION=$(git rev-parse --short HEAD)

help:			## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

login:			## login github registory
	echo $${GH_PAT} | docker login ghcr.io -u $(REPO_USER) --password-stdin

build:			## build 
	ko build .

create-sp:		## create service principal for GitHub Action 
	APP_ID=$$(az ad sp create-for-rbac --name "$(RESOURCE_GROUP)-sp" --role contributor --scopes "/subscriptions/$(SUBSCRIPTION_ID)/resourceGroups/$(RESOURCE_GROUP)" --query appId -o tsv) \
	&& echo "id: $${APP_ID}" \
	&& OID=$$(az ad app show --id $${APP_ID} --query id -o tsv) \
	&& echo "oid: $${OID}" \
	&& az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$${OID}/federatedIdentityCredentials" \
		--body "{ \
				'name':'$(RESOURCE_GROUP)-$(REPO_USER)-$(REPOSITORY_NAME)-cred', \
				'issuer':'https://token.actions.githubusercontent.com', \
				'subject':'repo:$(REPO_USER)/$(REPOSITORY_NAME):ref:refs/heads/$(BRANCH_NAME)', \
				'description':'GitHub Actions for $(RESOURCE_GROUP)', \
				'audiences':['api://AzureADTokenExchange'] \
			}"

show-fedcred:		## show service principal federated identity credentials
	APP_ID=$$(az ad app list --query '[?displayName == `$(SP_NAME)`].id' -o tsv) \
	&& echo "id: $${APP_ID}" \
	&& OID=$$(az ad app show --id $${APP_ID} --query id -o tsv) \
	&& echo "oid: $${OID}" \
	&& az rest --method GET --uri "https://graph.microsoft.com/beta/applications/$${OID}/federatedIdentityCredentials" 

set-gh-secret: 		## set GitHub secret for GitHub Action
set-gh-secret: tmp/.env
	gh secret set -f tmp/.env

tmp/.env:
	@echo "AZURE_CLIENT_ID=$$(az ad app list --query '[?displayName == `$(SP_NAME)`].appId' -o tsv)" > tmp/.env
	@echo "AZURE_TENANT_ID=$(TENANT_ID)" >> tmp/.env
	@echo "AZURE_SUBSCRIPTION_ID=$(SUBSCRIPTION_ID)" >> tmp/.env
	@echo "AZURE_RESOUCE_GROUP=$(RESOURCE_GROUP)" >> tmp/.env
	@echo "REGISTRY_USERNAME=$(REPO_USER)" >> tmp/.env
	@echo "REGISTRY_PASSWORD=${GH_PAT}" >> tmp/.env
	@echo "ENVIRONMENT_NAME=$(ENVIRONMENT_NAME)" >> tmp/.env
	@echo "CONTAINERAPPS_NAME=$(CONTAINERAPPS_NAME)" >> tmp/.env

deploy-apps:		## deploy app
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy/main.bicep \
	-p \
	containerAppName=$(CONTAINERAPPS_NAME) \
	environmentName=$(ENVIRONMENT_NAME) \
	containerImage=$$(ko build .) \
	containerPort=8080


ifndef VERBOSE
.SILENT:
endif

##: ## Set VERBOSE=1 to echo commands while running

help: ## List targets & descriptions
	@cat Makefile* | grep -E '^[#a-zA-Z_/-]+:.*?## .*$$' | sort -V | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Install third-party plugins
	packer init .

validate: ## Validate packer manifests
	packer validate .

format: ## Format packer manifests
	packer fmt .

build-docker: ## Build docker image
	packer build --only=docker.* --var-file=example.pkrvars.hcl example.pkr.hcl

build-ami: ## Build AMI
	packer build --only=amazon-ebs.* --var-file=example.pkrvars.hcl example.pkr.hcl

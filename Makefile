VERSION=v1
# ---------- Packer ----------
PACKER=packer
PACKER_DIR=packer
VAR_FILE=variables.pkrvars.hcl

pk-init:
	cd $(PACKER_DIR) && $(PACKER) init .

pk-validate:
	cd $(PACKER_DIR) && $(PACKER) validate -var-file=$(VAR_FILE) .

pk-build:
	cd $(PACKER_DIR) && $(PACKER) build \
	-var 'image_version=$(VERSION)' \
	-var-file=$(VAR_FILE) .

pk-debug:
	cd $(PACKER_DIR) && PACKER_LOG=1 $(PACKER) build -var-file=$(VAR_FILE) .

# ---------- Terraform ----------
TERRAFORM=terraform
TF_DIR=terraform
TFVARS=terraform.tfvars

tf-init:
	cd $(TF_DIR) && $(TERRAFORM) init

tf-fmt:
	cd $(TF_DIR) && $(TERRAFORM) fmt -recursive

tf-validate:
	cd $(TF_DIR) && $(TERRAFORM) validate

tf-plan:
	cd $(TF_DIR) && $(TERRAFORM) plan -var-file=$(TFVARS)

tf-apply:
	cd $(TF_DIR) && $(TERRAFORM) apply \
	-var "base_image=../images/debian13-template-$(VERSION)/debian13-template-$(VERSION)" \
	-var-file=$(TFVARS) -auto-approve

tf-destroy:
	cd $(TF_DIR) && $(TERRAFORM) destroy -var-file=$(TFVARS)

tf-rebuild: tf-destroy tf-apply
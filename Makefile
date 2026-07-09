VERSION=v2
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
TFVARS=terraform.tfvars
# libvirt
LIBVIRT_DIR=terraform/libvirt

tf-libvirt-init:
	cd $(LIBVIRT_DIR) && $(TERRAFORM) init

tf-libvirt-fmt:
	cd $(LIBVIRT_DIR) && $(TERRAFORM) fmt -recursive

tf-libvirt-validate:
	cd $(LIBVIRT_DIR) && $(TERRAFORM) validate

tf-libvirt-plan:
	cd $(LIBVIRT_DIR) && $(TERRAFORM) plan -var-file=$(TFVARS)

tf-libvirt-apply:
	cd $(LIBVIRT_DIR) && $(TERRAFORM) apply \
	-var "base_image=../images/debian13-template-$(VERSION)/debian13-template-$(VERSION)" \
	-var-file=$(TFVARS) -auto-approve

tf-libvirt-destroy:
	cd $(LIBVIRT_DIR) && $(TERRAFORM) destroy -var-file=$(TFVARS)

tf-libvirt-rebuild: tf-libvirt-destroy tf-libvirt-apply
# -------------
# aws
AWS_DIR=terraform/aws

tf-aws-init:
	cd $(AWS_DIR) && $(TERRAFORM) init

tf-aws-fmt:
	cd $(AWS_DIR) && $(TERRAFORM) fmt -recursive

tf-aws-validate:
	cd $(AWS_DIR) && $(TERRAFORM) validate

tf-aws-plan:
	cd $(AWS_DIR) && $(TERRAFORM) plan -var-file=$(TFVARS)

tf-aws-apply:
	cd $(AWS_DIR) && $(TERRAFORM) apply \
	-var "base_image=../images/debian13-template-$(VERSION)/debian13-template-$(VERSION)" \
	-var-file=$(TFVARS) -auto-approve

tf-aws-destroy:
	cd $(AWS_DIR) && $(TERRAFORM) destroy -var-file=$(TFVARS)

tf-aws-rebuild: tf-libvirt-destroy tf-libvirt-apply
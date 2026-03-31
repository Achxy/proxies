TF_DIR := infra/terraform

.PHONY: init plan deploy destroy logs status restart update open fmt bootstrap-state migrate-state

# Terraform requires >= 1.11.0 for write-only secret attributes.
# Install the latest via: brew upgrade terraform
# Or: https://developer.hashicorp.com/terraform/install

init: ## Initialize Terraform with GCS remote backend
	cd $(TF_DIR) && terraform init -backend-config=backend.tfbackend

fmt: ## Format Terraform files
	cd $(TF_DIR) && terraform fmt

plan: ## Show pending changes
	cd $(TF_DIR) && terraform plan

deploy: ## Apply all infrastructure changes
	cd $(TF_DIR) && terraform apply

destroy: ## Destroy all infrastructure
	@echo ""
	@echo "NOTE: The Cloud Run service has deletion_protection = true."
	@echo "Before running destroy, temporarily set deletion_protection = false"
	@echo "in service.tf, then: terraform apply -target=google_cloud_run_v2_service.proxy"
	@echo ""
	cd $(TF_DIR) && terraform destroy

update: ## Deploy a specific image version: make update IMAGE_TAG=v6.9.7
	@[ -n "$(IMAGE_TAG)" ] || (echo "Usage: make update IMAGE_TAG=v6.9.7"; exit 1)
	cd $(TF_DIR) && terraform apply -var="image_tag=$(IMAGE_TAG)"

logs: ## Tail Cloud Run logs
	@gcloud run services logs read proxies-llm \
		--project=$$(cd $(TF_DIR) && terraform output -raw gcp_project) \
		--region=$$(cd $(TF_DIR) && terraform output -raw gcp_region) \
		--limit=50

status: ## Show Cloud Run service status
	@gcloud run services describe proxies-llm \
		--project=$$(cd $(TF_DIR) && terraform output -raw gcp_project) \
		--region=$$(cd $(TF_DIR) && terraform output -raw gcp_region) \
		--format="yaml(status)"

restart: ## Force a new Cloud Run revision (picks up latest secret version)
	@gcloud run services update proxies-llm \
		--project=$$(cd $(TF_DIR) && terraform output -raw gcp_project) \
		--region=$$(cd $(TF_DIR) && terraform output -raw gcp_region) \
		--no-traffic

open: ## Open the management dashboard in a browser
	@open $$(cd $(TF_DIR) && terraform output -raw dashboard_url)

bootstrap-state: ## Create the GCS state bucket (run once, before 'make init')
	@[ -n "$(GCP_PROJECT)" ] || (echo "Usage: make bootstrap-state GCP_PROJECT=your-project-id"; exit 1)
	@gcloud storage buckets create gs://$(GCP_PROJECT)-terraform-state \
		--project=$(GCP_PROJECT) \
		--location=us-central1 \
		--uniform-bucket-level-access
	@gcloud storage buckets update gs://$(GCP_PROJECT)-terraform-state --versioning
	@cp $(TF_DIR)/backend.tfbackend.example $(TF_DIR)/backend.tfbackend
	@sed -i '' 's/YOUR_GCP_PROJECT_ID/$(GCP_PROJECT)/' $(TF_DIR)/backend.tfbackend
	@echo ""
	@echo "State bucket created and backend.tfbackend written."
	@echo "Now run: make init"

migrate-state: ## Migrate existing local state to the GCS backend
	cd $(TF_DIR) && terraform init -migrate-state -backend-config=backend.tfbackend

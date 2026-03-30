TF_DIR := infra/terraform

.PHONY: init plan deploy destroy ssh logs status restart update open fmt

init:
	cd $(TF_DIR) && terraform init

fmt:
	cd $(TF_DIR) && terraform fmt

plan:
	cd $(TF_DIR) && terraform plan

deploy:
	cd $(TF_DIR) && terraform apply

destroy:
	cd $(TF_DIR) && terraform destroy

logs:
	@echo "Opening Cloud Run logs in browser..."
	@gcloud run services logs read proxies-llm --project=$$(cd $(TF_DIR) && terraform output -raw gcp_project) --region=$$(cd $(TF_DIR) && terraform output -raw gcp_region) --limit=50

status:
	@gcloud run services describe proxies-llm --project=$$(cd $(TF_DIR) && terraform output -raw gcp_project) --region=$$(cd $(TF_DIR) && terraform output -raw gcp_region) --format="yaml(status)"

restart:
	@gcloud run services update proxies-llm --project=$$(cd $(TF_DIR) && terraform output -raw gcp_project) --region=$$(cd $(TF_DIR) && terraform output -raw gcp_region) --no-traffic

update:
	@gcloud run services update proxies-llm --project=$$(cd $(TF_DIR) && terraform output -raw gcp_project) --region=$$(cd $(TF_DIR) && terraform output -raw gcp_region) --image=docker.io/eceasy/cli-proxy-api:latest

open:
	@open $$(cd $(TF_DIR) && terraform output -raw custom_url)

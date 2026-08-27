.PHONY: up down build logs test-build validate-manifests validate-iac validate security

up:
	docker compose up --build -d
	@echo "Miljøet kjører. Security Radar: http://localhost:5080"

down:
	docker compose down

build:
	docker compose build

logs:
	docker compose logs -f

test-build:
	dotnet build src/Showcase.Api/Showcase.Api.csproj
	dotnet build apps/care-portal/CarePortal.Api/CarePortal.Api.csproj
	dotnet build apps/community-hub/CommunityHub.Api/CommunityHub.Api.csproj
	dotnet build apps/security-radar/SecurityRadar.Web/SecurityRadar.Web.csproj
	@echo "Alle .NET API-tjenester er bygget."

validate-manifests:
	@python -m pip install --disable-pip-version-check --quiet pyyaml
	@python scripts/validate_manifests.py

validate-iac:
	terraform -chdir=infra/terraform fmt -check -recursive
	terraform -chdir=infra/terraform init -backend=false
	terraform -chdir=infra/terraform validate

validate: validate-manifests validate-iac test-build

security: validate
	@echo "Security/IaC validation passed."

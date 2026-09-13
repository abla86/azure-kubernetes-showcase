.PHONY: up up-observability down build logs test-build validate-manifests validate-iac validate security cost-audit smoke

up:
	docker compose up --build -d
	@echo "Miljøet kjører. Security Radar: http://localhost:5080"

up-observability:
	OTEL_ENABLED=true docker compose --profile observability up --build -d
	@echo "Miljøet kjører med OTEL Collector aktivert. Security Radar: http://localhost:5080"

down:
	docker compose down -v

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
	python scripts/validate_manifests.py

validate-iac:
	terraform -chdir=infra/terraform fmt -check -recursive
	terraform -chdir=infra/terraform init -backend=false -input=false
	terraform -chdir=infra/terraform validate
	az bicep build --file infra/bicep/main.bicep --stdout > $null

validate: validate-manifests validate-iac

security:
	python security/api-self-test.py

cost-audit:
	python scripts/cloud_waste_audit.py

smoke:
	python scripts/local_smoke_test.py

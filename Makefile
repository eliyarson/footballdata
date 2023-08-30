.phony: up down build up-infra

up-infra:
	@docker compose up -d

up: up-infra

down:
	@docker compose down --remove-orphans

build:
	@docker build -t app -f app/.docker/Dockerfile app

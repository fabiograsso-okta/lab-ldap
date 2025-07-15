# Makefile for managing the LDAP Docker environment
-include .env
export

# This ensures that targets like 'start' don't conflict with a file named 'start'.
.PHONY: help start start-logs stop stop-logs restart restart-logs logs build configure check-prereqs

# Default target when 'make' is run without arguments.
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  start  		- Checks prerequisites, starts containers in the background."
	@echo "  stop           - Stops and removes all containers."
	@echo "  restart        - Restarts containers in the background."
	@echo "  logs           - Follows container logs."
	@echo "  start-logs     - Checks prerequisites, starts containers, and follows logs."
	@echo "  stop-logs      - Stops and removes all containers, showing latest logs."
	@echo "  restart-logs   - Restarts containers and follows logs."
	@echo "  build          - Forces a rebuild of the images from scratch."
	@echo "  configure      - Runs the interactive Okta agent configuration script."
	@echo "  check-prereqs  - Runs prerequisite checks without starting the services."

start: check-prereqs
	@echo "--> Starting containers in detached mode..."
	@docker-compose up -d

stop:
	@echo "--> Stopping containers..."
	@docker-compose down

restart: stop start

logs:
	@echo "--> Tailing logs..."
	@docker-compose logs -f --tail=500

start-logs: check-prereqs
	@echo "--> Starting containers and attaching logs..."
	@docker-compose up

stop-logs:
	@echo "--> Stopping containers..."
	@docker-compose down

restart-logs: stop-logs start-logs

build:
	@echo "--> Forcing a rebuild of all images..."
	@docker-compose build --no-cache --parallel --pull --force-rm

configure:
	@echo "--> Launching Okta agent configuration script..."
	@docker-compose exec okta-agent /opt/Okta/OktaLDAPAgent/scripts/configure_agent.sh

check-prereqs:
	@echo "--> Checking prerequisites..."
	@# 1. Check for the Okta agent installer file
	@if ! ls ./okta-agent/OktaLDAPAgent-*.deb 1>/dev/null 2>&1; then \
		echo "\033[0;31mERROR: Okta Agent installer (.deb) not found!\033[0m"; \
		echo "Please place the downloaded agent file in the './okta-agent/' directory."; \
		exit 1; \
	fi
	@echo "  [✔] Okta Agent installer found."
	@# 2. Check that specific required variables are not empty
	@for var in OKTA_ORG LDAP_ORGANISATION LDAP_DOMAIN LDAP_BASE_DN LDAP_ADMIN_PASSWORD; do \
		if [ -z "$${!var}" ]; then \
			echo "\033[0;31mERROR: Environment variable '$${var}' is not set or is empty.\033[0m"; \
			echo "Please check your .env file."; \
			exit 1; \
		fi; \
	done
	@echo "  [✔] Required environment variables are set."
	@echo "--> Prerequisites check passed."
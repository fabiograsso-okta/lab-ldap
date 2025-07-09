.PHONY: start stop restart logs build start-logs restart-logs configure

start :
	@docker-compose up -d

stop :
	@docker-compose down

restart : stop start

logs :
	@docker-compose logs -f --tail=500

build :
	@docker-compose build  --no-cache --parallel --pull --force-rm

start-logs : start logs

restart-logs : restart logs

configure : 
	@docker exec -it $(docker ps --filter "label=com.docker.compose.service=okta-ldap-agent" --format "{{.ID}}") /opt/Okta/OktaLDAPAgent/scripts/configure_agent.sh

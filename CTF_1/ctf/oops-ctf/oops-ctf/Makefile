# Conveniència per gestionar tot el laboratori des de l'arrel.
# Cada màquina és independent (té el seu propi docker-compose.yml),
# però aquestes ordres actuen sobre totes alhora.

MACHINES = oops1 oops2 oops3 oops4 oops5

.PHONY: net up down build ps logs clean

net:            ## Crea les xarxes compartides (fer un cop)
	@bash setup-networks.sh

up: net         ## Aixeca totes les màquines
	@for m in $(MACHINES); do echo ">> up $$m"; (cd $$m && docker compose up -d --build); done
	@docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

build:          ## Només construeix les imatges
	@for m in $(MACHINES); do echo ">> build $$m"; (cd $$m && docker compose build); done

down:           ## Atura totes les màquines
	@for m in $(MACHINES); do echo ">> down $$m"; (cd $$m && docker compose down); done

ps:             ## Estat
	@docker ps --filter "name=oops" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

clean: down     ## Atura-ho tot i esborra les xarxes
	@docker network rm oops_dmz oops_internal 2>/dev/null || true

# Per una màquina sola:  cd oops1 && docker compose up -d --build

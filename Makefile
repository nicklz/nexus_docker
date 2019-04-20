include .env

.PHONY: up down stop prune ps shell dbdump dbrestore uli cim cex

default: up

up:
	@echo "Starting up containers for for $(PROJECT_NAME)..."
	docker-compose$(WINDOWS_SUPPORT) pull
	docker-compose$(WINDOWS_SUPPORT) up -d --remove-orphans
	@echo "Syncing folders... this may take a few minutes"
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(shell docker$(WINDOWS_SUPPORT) ps --filter name='$(PROJECT_NAME)_nginx' --format '{{ .ID }}') sh -c  'apk add rsync'
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(shell docker$(WINDOWS_SUPPORT) ps --filter name='$(PROJECT_NAME)_php' --format '{{ .ID }}') sh -c  'apk add rsync'
	
	@echo "-------------------------------------------------"
	@echo "-------------------------------------------------"
	@echo "-------------------------------------------------"
	@echo "Visit http://$(PROJECT_BASE_URL):$(PROJECT_PORT)"
	@echo "-------------------------------------------------"
	@echo "-------------------------------------------------"
	@echo "-------------------------------------------------"


	while true; do make rsync; done;




down:
	@echo "Removing containers."
	docker-compose$(WINDOWS_SUPPORT) down

rsync:
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(shell docker$(WINDOWS_SUPPORT) ps --filter name='$(PROJECT_NAME)_nginx' --format '{{ .ID }}') sh -c  'rsync -aW --inplace --no-compress --delete --exclude node_modules --exclude .git --exclude vendor/bin/phpcbf --exclude vendor/zendframework/zend-escaper/doc  --exclude vendor/zendframework/zend-feed/doc --exclude vendor/zendframework/zend-stdlib/doc  --exclude vendor/bin/phpcs --exclude vendor/bin --exclude vendor/bin/phpunit --exclude vendor/bin/simple-phpunit /var/www/html/web /rsync ' && docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(shell docker$(WINDOWS_SUPPORT) ps --filter name='$(PROJECT_NAME)_php' --format '{{ .ID }}') sh -c  'rsync -aW --inplace --no-compress --delete --exclude node_modules --exclude .git --exclude vendor/bin/phpcbf --exclude vendor/zendframework/zend-escaper/doc  --exclude vendor/zendframework/zend-feed/doc --exclude vendor/zendframework/zend-stdlib/doc  --exclude vendor/bin/phpcs --exclude vendor/bin --exclude vendor/bin/phpunit --exclude vendor/bin/simple-phpunit /var/www/html/web /rsync '


stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose$(WINDOWS_SUPPORT) stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose$(WINDOWS_SUPPORT) down -v

ps:
	@docker$(WINDOWS_SUPPORT) ps --filter name="$(PROJECT_NAME)*"

shell:
	docker$(WINDOWS_SUPPORT) exec -u 0 -ti $(shell docker$(WINDOWS_SUPPORT) ps --filter name='$(PROJECT_NAME)_php' --format '{{ .ID }}') sh

nginx:
	docker$(WINDOWS_SUPPORT) exec  -u 0 -ti $(shell docker$(WINDOWS_SUPPORT) ps --filter name='$(PROJECT_NAME)_nginx' --format '{{ .ID }}') sh

dbdump:
	@echo "Creating Database Dump for $(PROJECT_NAME)..."
	docker-compose$(WINDOWS_SUPPORT) run php drupal database:dump --file=../db/restore.sql --gz

dbrestore:
	@echo "Restoring database..."
	docker-compose$(WINDOWS_SUPPORT) run php drupal database:restore --file='/var/www/html/db/restore.sql.gz'

uli:
	@echo "Getting admin login"
	docker-compose$(WINDOWS_SUPPORT) run php drush user:login --uri="$(PROJECT_BASE_URL)":$(PROJECT_PORT)

cim:
	@echo "Importing Configuration"
	docker-compose$(WINDOWS_SUPPORT) run php drupal config:import -y

cex:
	@echo "Exporting Configuration"
	docker-compose$(WINDOWS_SUPPORT) run php drupal config:export -y

gm:
	@echo "Displaying Generate Module UI"
	docker-compose$(WINDOWS_SUPPORT) run php drupal generate:module

install-source:
	@echo "Installing dependencies"
	docker-compose$(WINDOWS_SUPPORT) run php composer install --prefer-source

install:
	@echo "Installing dependencies"
	composer install
	@echo "Cleaning up workspace"
	rm -rf web > /dev/null 2>&1
	@echo "Cloning codebase"
	git clone $(PROJECT_GIT) web
	docker-compose$(WINDOWS_SUPPORT) run php composer install
	cp settings-templates/settings.php web/docroot/sites/default/settings.php

cr:
	@echo "Clearing Drupal Caches"
	docker-compose$(WINDOWS_SUPPORT) run php drupal cache:rebuild all

logs:
	@echo "Displaying past containers logs"
	docker-compose$(WINDOWS_SUPPORT) logs

logsf:
	@echo "Follow containers logs output"
	docker-compose$(WINDOWS_SUPPORT) logs -f

dbclient:
	@echo "Opening DB client"
	docker-compose$(WINDOWS_SUPPORT) run php drupal database:client

behat:
	@echo "Running behat tests"
	docker-compose$(WINDOWS_SUPPORT) run php vendor/bin/behat

phpcs:
	@echo "Running coding standards on custom code"
	docker-compose$(WINDOWS_SUPPORT) run php vendor/bin/phpcs --standard=vendor/drupal/coder/coder_sniffer/Drupal web/modules/custom --ignore=*.min.js --ignore=*.min.css

phpcbf:
	@echo "Beautifying custom code"
	docker-compose$(WINDOWS_SUPPORT) run php vendor/bin/phpcbf --standard=vendor/drupal/coder/coder_sniffer/Drupal web/modules/custom --ignore=*.min.js --ignore=*.min.css

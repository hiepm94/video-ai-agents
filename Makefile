ifeq (,$(wildcard .env))
$(error .env file is missing at . Please create one based on .env.example)
endif

include .env	
	
build-vaas:
	docker compose build

start-vaas:
	docker compose up --build -d

stop-vaas:
	docker compose stop

build:
	docker compose build web

run:
	docker compose up

bash:
	docker compose run -it --rm web bash

c:
	docker compose run -it --rm web bin/rails c

setup:
	make build
	docker compose run -it --rm web bin/setup
	make run

setup:
	docker compose build
	docker compose run -it --rm web bin/setup
	docker compose up

run:
	docker compose up

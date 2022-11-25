build:
	docker build --platform linux/amd64 -t heapoverflow:2.0.2 .

run:
	docker compose up

setup:
	build
	docker compose run -it --rm web bin/setup
	run

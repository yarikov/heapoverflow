build:
	docker build --platform linux/amd64 -t heapoverflow:2.0.3 .

run:
	docker compose up

c:
	docker compose run -it --rm web

setup:
	build
	docker compose run -it --rm web bin/setup
	run

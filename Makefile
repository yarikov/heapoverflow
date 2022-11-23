setup:
	docker build --platform linux/amd64 -t heapoverflow:2.0.0 .
	docker compose run -it --rm web bin/setup
	docker compose up

run:
	docker compose up

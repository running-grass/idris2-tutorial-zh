pwd :=$(shell pwd)

.PHONY: build-docker
build-docker:
	docker build -t idris2-tutorial:dev .

.PHONY: update
update: build-docker
	docker run --rm -v ${pwd}:/work idris2-tutorial:dev

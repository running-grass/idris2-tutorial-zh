root :=$(dir $(shell pwd))


.PHONY: update
update: 
	./po4a-update.sh

.PHONY: build-docker
build-docker:
	docker build --pull=false -t idris2-tutorial:dev .


.PHONY: debug
debug: build-docker
	docker run -it --rm -v ${root}:/work --entrypoint /bin/bash idris2-tutorial:dev

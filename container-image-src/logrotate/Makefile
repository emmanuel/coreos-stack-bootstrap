container = logrotate
docker_account = nordstrom
tag = latest

build/container: dist/docker-gen.tar.gz dist/go-cron.tar.gz
	docker build --no-cache -t $(container) .
	mkdir -p build
	touch build/container

run/container:
	docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker $(container)

release:
	docker tag $(container) $(docker_account)/$(container):$(tag)
	docker push $(docker_account)/$(container):$(tag)

.PHONY: clean
clean:
	rm -rf build


docker-gen: dist/docker-gen.tar.gz

dist/docker-gen.tar.gz: 
	curl -sLo dist/docker-gen.tar.gz https://github.com/jwilder/docker-gen/releases/download/0.3.2/docker-gen-linux-amd64-0.3.2.tar.gz

go-cron: dist/go-cron.tar.gz

dist/go-cron.tar.gz: 
	curl -sLo dist/go-cron.tar.gz https://github.com/michaloo/go-cron/releases/download/v0.0.2/go-cron.tar.gz

container_name := baseimage-alpine
registry := nordstrom
release := 3.2

build/container:
	docker build -t $(container_name) .

release/container:
	docker tag -f $(container_name) $(registry)/$(container_name):$(release)
	docker push $(registry)/$(container_name):$(release)

docker_account = docker.cloud.nlab.io
release = 1.5.0.beta1
download_url = https://github.com/elasticsearch/logstash/archive/v$(release).tar.gz

build/container: dist/logstash-$(release).tar.gz
	docker build --no-cache -t logstash .
	mkdir -p build
	touch build/container

release:
	docker tag logstash nordstrom/logstash:$(release)
	docker push nordstrom/logstash:$(release)

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/logstash-$(release).tar.gz: 
	curl -sLo dist/logstash-$(release).tar.gz $(download_url)

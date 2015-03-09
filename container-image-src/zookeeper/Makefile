docker_account = nordstrom
release = 3.4.6
download_url = http://www.us.apache.org/dist/zookeeper/zookeeper-$(release)/zookeeper-$(release).tar.gz

build/container: dist/zookeeper-$(release).tar.gz
	docker build --no-cache -t zookeeper .
	mkdir -p build
	touch build/container

release:
	docker tag -f zookeeper nordstrom/zookeeper:$(release)
	docker push nordstrom/zookeeper:$(release)

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/zookeeper-$(release).tar.gz: 
	curl -sLo dist/zookeeper-$(release).tar.gz $(download_url)

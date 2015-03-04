release = 0.8.8
download_url = http://s3.amazonaws.com/influxdb/influxdb_$(release)_amd64.deb

build/container: dist/influxdb_$(release)_amd64.deb
	docker build --no-cache -t influxdb .
	mkdir -p build
	touch build/container

release: build/container
	docker tag -f influxdb nordstrom/influxdb:$(release)
	docker push nordstrom/influxdb:$(release)

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/influxdb_$(release)_amd64.deb: 
	curl -sLo dist/influxdb_$(release)_amd64.deb $(download_url)

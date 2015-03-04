release = 0.8.0-beta.2
download_url = https://github.com/mailgun/vulcand/releases/download/v$(release)/vulcand-v$(release)-linux-amd64.tar.gz

release:
	docker tag -f influxdb nordstrom/vulcand:$(release)
	docker push nordstrom/vulcand:$(release)

build/container: dist/vulcand-v$(release)-linux-amd64
	docker build --no-cache -t vulcand .
	mkdir -p build
	touch build/container

run/container: build/container
	docker run --rm --name vulcand vulcand

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/vulcand-v$(release)-linux-amd64: 
	curl -sLo dist/vulcand-v$(release)-linux-amd64.tar.gz $(download_url)
	tar xzf dist/vulcand-v$(release)-linux-amd64.tar.gz
	mv vulcand-v$(release)-linux-amd64 dist/

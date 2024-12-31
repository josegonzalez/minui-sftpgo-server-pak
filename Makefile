TAG ?= v2.6.4
BUILD_DATE := "$(shell date -u +%FT%TZ)"

clean:
	rm -rf bin/evtest || true
	rm -rf bin/sftpgo || true
	rm -rf sftpgo || true

build: bin/evtest bin/sftpgo

sftpgo:
	git clone https://github.com/drakkan/sftpgo
	cd sftpgo && git checkout "tags/${TAG}"

bin/sftpgo: sftpgo
	mkdir -p bin/sftpgo
	docker buildx build --platform linux/arm64 --load --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.sftpgo --progress plain -t app/sftpgo:$(TAG) .
	docker container create --name extract app/sftpgo:$(TAG)
	docker container cp extract:/go/src/github.com/drakkan/sftpgo/sftpgo bin/sftpgo/sftpgo
	docker container rm extract
	chmod +x bin/sftpgo/sftpgo

	cp -r sftpgo/templates bin/sftpgo/templates
	cp -r sftpgo/static bin/sftpgo/static
	cp sftpgo/sftpgo.json bin/sftpgo/sftpgo.json
	cp sftpgo/LICENSE bin/sftpgo/LICENSE

	jq --arg value "0" '.sftpd.bindings[0].port = ($$value|tonumber)' bin/sftpgo/sftpgo.json > bin/sftpgo/sftpgo.json.tmp && mv bin/sftpgo/sftpgo.json.tmp bin/sftpgo/sftpgo.json

	jq --arg value "21" '.ftpd.bindings[0].port = ($$value|tonumber)' bin/sftpgo/sftpgo.json > bin/sftpgo/sftpgo.json.tmp && mv bin/sftpgo/sftpgo.json.tmp bin/sftpgo/sftpgo.json

	jq --arg value "false" '.httpd.bindings[0].enable_web_admin = ($$value|test("true"))' bin/sftpgo/sftpgo.json > bin/sftpgo/sftpgo.json.tmp && mv bin/sftpgo/sftpgo.json.tmp bin/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_admin.name = $$value' bin/sftpgo/sftpgo.json > bin/sftpgo/sftpgo.json.tmp && mv bin/sftpgo/sftpgo.json.tmp bin/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_admin.short_name = $$value' bin/sftpgo/sftpgo.json > bin/sftpgo/sftpgo.json.tmp && mv bin/sftpgo/sftpgo.json.tmp bin/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_client.name = $$value' bin/sftpgo/sftpgo.json > bin/sftpgo/sftpgo.json.tmp && mv bin/sftpgo/sftpgo.json.tmp bin/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_client.short_name = $$value' bin/sftpgo/sftpgo.json > bin/sftpgo/sftpgo.json.tmp && mv bin/sftpgo/sftpgo.json.tmp bin/sftpgo/sftpgo.json

bin/evtest:
	docker buildx build --platform linux/arm64 --load --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.evtest --progress plain -t app/evtest:$(TAG) .
	docker container create --name extract app/evtest:$(TAG)
	docker container cp extract:/go/src/github.com/freedesktop/evtest/evtest bin/evtest
	docker container rm extract
	chmod +x bin/evtest

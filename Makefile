TAG ?= v2.6.4
BUILD_DATE := "$(shell date -u +%FT%TZ)"
PAK_NAME := $(shell jq -r .label config.json)

PLATFORMS := tg5040 rg35xxplus
MINUI_LIST_VERSION := 0.4.0

clean:
	rm -rf bin/sftpgo || true
	rm -rf sftpgo || true
	rm -f bin/minui-list-* || true
	rm -f bin/sdl2imgshow || true
	rm -f res/fonts/BPreplayBold.otf || true

build: $(foreach platform,$(PLATFORMS),bin/minui-list-$(platform)) bin/sftpgo bin/sdl2imgshow res/fonts/BPreplayBold.otf

sftpgo:
	git clone https://github.com/drakkan/sftpgo
	cd sftpgo && git checkout "tags/${TAG}"

bin/minui-list-%:
	curl -f -o bin/minui-list-$* -sSL https://github.com/josegonzalez/minui-list/releases/download/$(MINUI_LIST_VERSION)/minui-list-$*
	chmod +x bin/minui-list-$*

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

bin/sdl2imgshow:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.sdl2imgshow --progress plain -t app/sdl2imgshow:$(TAG) .
	docker container create --name extract app/sdl2imgshow:$(TAG)
	docker container cp extract:/go/src/github.com/kloptops/sdl2imgshow/build/sdl2imgshow bin/sdl2imgshow
	docker container rm extract
	chmod +x bin/sdl2imgshow

res/fonts/BPreplayBold.otf:
	mkdir -p res/fonts
	curl -sSL -o res/fonts/BPreplayBold.otf "https://raw.githubusercontent.com/shauninman/MinUI/refs/heads/main/skeleton/SYSTEM/res/BPreplayBold-unhinted.otf"

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist

PAK_NAME := $(shell jq -r .label config.json)

ARCHITECTURES := arm64
PLATFORMS := rg35xxplus tg5040

JQ_VERSION ?= 1.7.1
MINUI_LIST_VERSION := 0.6.1
MINUI_PRESENTER_VERSION := 0.3.1
SFTPGO_VERSION := v2.6.6

clean:
	rm -f bin/*/jq || true
	rm -f bin/*/sftpgo || true
	rm -f bin/*/minui-list || true
	rm -f bin/*/minui-presenter || true
	rm -rf sftpgo || true

build: $(foreach platform,$(PLATFORMS),bin/$(platform)/minui-list bin/$(platform)/minui-presenter) $(foreach arch,$(ARCHITECTURES),bin/$(arch)/sftpgo bin/$(arch)/jq)

sftpgo:
	git clone https://github.com/drakkan/sftpgo
	cd sftpgo && git checkout "tags/${SFTPGO_VERSION}"

bin/arm64/jq:
	mkdir -p bin/arm64
	curl -f -o bin/arm64/jq -sSL https://github.com/jqlang/jq/releases/download/jq-$(JQ_VERSION)/jq-linux-arm64
	curl -sSL -o bin/arm64/jq.LICENSE "https://raw.githubusercontent.com/jqlang/jq/refs/heads/$(JQ_VERSION)/COPYING"

bin/arm64/sftpgo: sftpgo
	mkdir -p bin/arm64/sftpgo
	curl -sSL https://github.com/drakkan/sftpgo/releases/download/$(SFTPGO_VERSION)/sftpgo_$(SFTPGO_VERSION)_linux_arm64.tar.xz | tar -x -C bin/arm64/sftpgo
	chmod +x bin/arm64/sftpgo/sftpgo

	cp -r sftpgo/templates bin/arm64/sftpgo/templates
	cp -r sftpgo/static bin/arm64/sftpgo/static
	cp sftpgo/sftpgo.json bin/arm64/sftpgo/sftpgo.json
	cp sftpgo/LICENSE bin/arm64/sftpgo/LICENSE

	jq --arg value "0" '.sftpd.bindings[0].port = ($$value|tonumber)' bin/arm64/sftpgo/sftpgo.json > bin/arm64/sftpgo/sftpgo.json.tmp && mv bin/arm64/sftpgo/sftpgo.json.tmp bin/arm64/sftpgo/sftpgo.json

	jq --arg value "21" '.ftpd.bindings[0].port = ($$value|tonumber)' bin/arm64/sftpgo/sftpgo.json > bin/arm64/sftpgo/sftpgo.json.tmp && mv bin/arm64/sftpgo/sftpgo.json.tmp bin/arm64/sftpgo/sftpgo.json

	jq --arg value "false" '.httpd.bindings[0].enable_web_admin = ($$value|test("true"))' bin/arm64/sftpgo/sftpgo.json > bin/arm64/sftpgo/sftpgo.json.tmp && mv bin/arm64/sftpgo/sftpgo.json.tmp bin/arm64/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_admin.name = $$value' bin/arm64/sftpgo/sftpgo.json > bin/arm64/sftpgo/sftpgo.json.tmp && mv bin/arm64/sftpgo/sftpgo.json.tmp bin/arm64/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_admin.short_name = $$value' bin/arm64/sftpgo/sftpgo.json > bin/arm64/sftpgo/sftpgo.json.tmp && mv bin/arm64/sftpgo/sftpgo.json.tmp bin/arm64/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_client.name = $$value' bin/arm64/sftpgo/sftpgo.json > bin/arm64/sftpgo/sftpgo.json.tmp && mv bin/arm64/sftpgo/sftpgo.json.tmp bin/arm64/sftpgo/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_client.short_name = $$value' bin/arm64/sftpgo/sftpgo.json > bin/arm64/sftpgo/sftpgo.json.tmp && mv bin/arm64/sftpgo/sftpgo.json.tmp bin/arm64/sftpgo/sftpgo.json

bin/%/minui-list:
	mkdir -p bin/$*
	curl -f -o bin/$*/minui-list -sSL https://github.com/josegonzalez/minui-list/releases/download/$(MINUI_LIST_VERSION)/minui-list-$*
	chmod +x bin/$*/minui-list

bin/%/minui-presenter:
	mkdir -p bin/$*
	curl -f -o bin/$*/minui-presenter -sSL https://github.com/josegonzalez/minui-presenter/releases/download/$(MINUI_PRESENTER_VERSION)/minui-presenter-$*
	chmod +x bin/$*/minui-presenter

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist

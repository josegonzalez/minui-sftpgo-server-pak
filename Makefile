TAG ?= v2.6.4
BUILD_DATE := "$(shell date -u +%FT%TZ)"

clean:
	rm -rf bin/sftpgo bin/templates bin/static bin/sftpgo.json bin/LICENSE || true

build:
	test -d sftpgo || git clone https://github.com/drakkan/sftpgo
	cd sftpgo && git checkout "tags/${TAG}"
	cd sftpgo && GOOS=linux GOARCH=arm64 go build -tags nogcs,nos3,nosqlite -ldflags "-s -w -X github.com/drakkan/sftpgo/v2/internal/version.commit=${TAG} -X github.com/drakkan/sftpgo/v2/internal/version.date=${BUILD_DATE}" -o sftpgo

	rm -rf bin/sftpgo bin/templates bin/static bin/sftpgo.json
	cp sftpgo/sftpgo bin/sftpgo
	cp -r sftpgo/templates bin/templates
	cp -r sftpgo/static bin/static
	cp sftpgo/sftpgo.json bin/sftpgo.json
	cp sftpgo/LICENSE bin/LICENSE

	jq --arg value "0" '.sftpd.bindings[0].port = ($$value|tonumber)' bin/sftpgo.json > bin/sftpgo.json.tmp && mv bin/sftpgo.json.tmp bin/sftpgo.json

	jq --arg value "21" '.ftpd.bindings[0].port = ($$value|tonumber)' bin/sftpgo.json > bin/sftpgo.json.tmp && mv bin/sftpgo.json.tmp bin/sftpgo.json

	jq --arg value "false" '.httpd.bindings[0].enable_web_admin = ($$value|test("true"))' bin/sftpgo.json > bin/sftpgo.json.tmp && mv bin/sftpgo.json.tmp bin/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_admin.name = $$value' bin/sftpgo.json > bin/sftpgo.json.tmp && mv bin/sftpgo.json.tmp bin/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_admin.short_name = $$value' bin/sftpgo.json > bin/sftpgo.json.tmp && mv bin/sftpgo.json.tmp bin/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_client.name = $$value' bin/sftpgo.json > bin/sftpgo.json.tmp && mv bin/sftpgo.json.tmp bin/sftpgo.json

	jq --arg value "TrimUI Brick" '.httpd.bindings[0].branding.web_client.short_name = $$value' bin/sftpgo.json > bin/sftpgo.json.tmp && mv bin/sftpgo.json.tmp bin/sftpgo.json

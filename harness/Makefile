.PHONY: openssl

all: openssl

openssl:
	mkdir -p temp/keys || true
	openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout temp/keys/key.pem -out temp/keys/cert.pem

clean:
	rm -fr temp/keys || true

#!/bin/sh
# Creates a self-signed code signing certificate in the login keychain.
# Signing every build with the same certificate keeps the app's code identity
# stable, so macOS keeps its Accessibility permission across rebuilds.
set -e

NAME="${1:-Little Fingers Local Signing}"

if security find-certificate -c "$NAME" >/dev/null 2>&1; then
	echo "Certificate \"$NAME\" already exists."
	exit 0
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/cert.cnf" <<CNF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $NAME
[ext]
basicConstraints = critical,CA:false
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
CNF

/usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
	-keyout "$TMP/key.pem" -out "$TMP/cert.pem" -config "$TMP/cert.cnf" 2>/dev/null
/usr/bin/openssl pkcs12 -export -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
	-name "$NAME" -out "$TMP/cert.p12" -passout pass:tmp 2>/dev/null

security import "$TMP/cert.p12" -k "$HOME/Library/Keychains/login.keychain-db" \
	-P tmp -T /usr/bin/codesign

echo "Created certificate \"$NAME\"."

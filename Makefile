default: help

BOUNDARY_VERSION := $(if ${BOUNDARY_VERSION},${BOUNDARY_VERSION},0.1.7)

ANSIBLE_OPTS := ${ANSIBLE_OPTS}

DOMAIN := boundary.example.com

SSL_DIR := ssl
SSL_CERT_PATH := $(SSL_DIR)/$(DOMAIN).crt
SSL_CSR_PATH := $(SSL_DIR)/$(DOMAIN).csr
SSL_KEY_PATH := $(SSL_DIR)/$(DOMAIN).key

help:
	@echo 'Usage: make [install|install-tls]'
	@echo '  Use `install` or `install-tls` for initial installtion.'

install:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts site.yml \
							  --extra-vars 'boundary_version=$(BOUNDARY_VERSION)' \
							  $(ANSIBLE_OPTS)

install-tls:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts site.yml \
							  --extra-vars 'boundary_version=$(BOUNDARY_VERSION)' \
							  --extra-vars 'boundary_tls_disable=false' \
							  --extra-vars 'boundary_api_tls_cert_src_file=$(SSL_CERT_PATH)' \
							  --extra-vars 'boundary_api_tls_key_src_file=$(SSL_KEY_PATH)' \
							  $(ANSIBLE_OPTS)

# Generate a certificate just for dev or test
cert:
	@mkdir -p $(SSL_DIR)
	openssl genrsa -out $(SSL_KEY_PATH) 4096
	openssl req -new -sha256 -out $(SSL_CSR_PATH) -key $(SSL_KEY_PATH) -config ssl.conf
	openssl x509 -req -sha256 -days 3650 \
		-in $(SSL_CSR_PATH) -signkey $(SSL_KEY_PATH) -out $(SSL_CERT_PATH) \
		-extensions req_ext -extfile ssl.conf

.PHONY: default install update help cert

.DEFAULT_GOAL := help
VENV_FOLDER := .venv
VENV_PATH := $(shell pwd)/$(VENV_FOLDER)
VENV_BIN := $(VENV_PATH)/bin
PACKAGER := uv

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##)|(^##)' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "; printf "Usage: make \033[32m<target>\033[0m\n"}{printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m## /\n[33m/'

install_uv: ## Install the packager
	@if ! command -v uv >/dev/null 2>&1; then \
		if ! command -v curl >/dev/null 2>&1; then \
			echo "curl could not be found, please install it first."; \
			exit 1; \
		else \
			echo "Installing uv..."; \
			curl -LsSf https://astral.sh/uv/install.sh | sh; \
		fi; \
	else \
		echo "uv is already installed."; \
	fi

create_venv: install_uv ## Create virtual environment
	@if [ ! -d "$(VENV_FOLDER)" ]; then \
		if ! command -v python &> /dev/null; then \
			python3 -m venv $(VENV_FOLDER); \
		else \
			python -m venv $(VENV_FOLDER); \
		fi \
	else \
		echo "Virtual environment already exists at $(VENV_PATH)"; \
	fi

venv: create_venv ## Load virtual environment
	. $(VENV_BIN)/activate


install: install_uv ## Install dependencies
	$(PACKAGER) sync


setup: install venv ## Setup Ansible environment
	ansible-galaxy install -r requirements.yml

run: setup ## Run Ansible playbook
	ansible-playbook playbook.yml -i hosts.yml

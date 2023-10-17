VENV_DIR := .venv
ACTIVATE := . ${VENV_DIR}/bin/activate
ANSIBLE_NAVIGATOR := true
HOST := kube-0

UPDATE_MANIFESTS := "false"

PIP := ${ACTIVATE}; pip

ifdef $(ANSIBLE_NAVIGATOR)
PLAYBOOK := ${ACTIVATE}; ansible-navigator run -i inventory/hosts.yaml site.yaml
else
PLAYBOOK := ${ACTIVATE}; ansible-playbook -i inventory/hosts.yaml site.yaml
endif

plan: ${HOST}

${HOST}: prerun
	@echo "Planning cluster..."
	@${PLAYBOOK} -e 'lifecycle="create"' --check --diff
	@echo "Done."

prerun:
	@echo "Running pre-run tasks..."
	@op user get --me
	@echo "Done."

etcd: prerun
	@echo "Installing etcd..."
	@./scripts/etcd.sh
	@echo "Done."

install: prerun
	@echo "Installing cluster..."
	@${PLAYBOOK} -e 'lifecycle="create" self_managed="true" update_manifests="true" install_dependencies="false"'
	@echo "Done."

cleanup: prerun
	@echo "Installing cluster..."
	@${PLAYBOOK} -e 'lifecycle="cleanup" self_managed="true" install_dependencies="false"'
	@echo "Done."

install-nav: prerun
	@echo "Installing cluster..."
	@./scripts/create.sh -n
	@echo "Done."

update: prerun
	@echo "Updating cluster..."
	@./scripts/update.sh .venv
	@echo "Done."

delete: prerun
	@echo "Uninstalling cluster..."
	@${PLAYBOOK} -e 'lifecycle="delete"'
	@echo "Done."

debug: prerun
	@echo "Installing cluster..."
	@${PLAYBOOK} --tags "syntax"
	@echo "Done."

${VENV_DIR}:
	@echo "Creating virtual environment..."
	@python3 -m venv ${VENV_DIR}

configure-venv: ${VENV_DIR}
	@echo "Installing dependencies..."
	@${PIP} install -r requirements.txt
	@${ACTIVATE}; ansible-galaxy collection install -r requirements.yaml
	@echo "Done."

.PHONY: install configure-venv update

.DEFAULT_GOAL := install

default: help

help:
	@echo 'Use `install` or `update` task'

install:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts --skip-tags update site.yml

update:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts --skip-tags install site.yml

.PHONY: default install update help

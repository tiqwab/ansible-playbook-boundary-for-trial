default: run

run:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -vvv site.yml

.PHONY: default main

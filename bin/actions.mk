.PHONY: files-import files-link check-ready check-live

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

host ?= localhost
max_try ?= 1
wait_seconds ?= 1
delay_seconds ?= 0
command ?=
service = Python

default: check-ready

migrate:
	sudo migrate $(from) $(to)

files-import:
	$(call check_defined, source)
	files_import $(source)

files-link:
	$(call check_defined, public_dir)
	files_link $(public_dir)

check-ready:
	wait_for "$(command)" $(service) $(host) $(max_try) $(wait_seconds) $(delay_seconds)

check-live:
	@echo "OK"

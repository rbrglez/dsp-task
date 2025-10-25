################################################################################
## User section: 
## add library paths to FUSESOC_LIBRARIES to register them with FuseSoC.
################################################################################

FUSESOC_LIBRARIES := \
	submodules/open-logic/src \
	submodules/xbc-testbench-utils \
	modules \
	targets

################################################################################
## Internal logic: do not modify below
################################################################################

all: setup

.PHONY: $(FUSESOC_LIBRARIES)
$(FUSESOC_LIBRARIES):
	fusesoc library add $@

.PHONY: setup
setup: $(FUSESOC_LIBRARIES)

.PHONY: clean
clean:
	rm -rf build/
	rm -f fusesoc.conf

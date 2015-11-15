
ifndef QUARTUS_ROOTDIR
$(error The environment variable QUARTUS_ROOTDIR is NOT set. \
This indicates that you are not running the Nios2 Command Shell. \
Execute /path/to/altera_dir/nios2eds/nios2_command_shell.sh and run make again. \
To find the path to the nios2_command_shell you can run the command "which quartus". \
This should give you "/path/to/altera_dir/quartus/bin/quartus" )
endif


# PROJECT_NAME must contain the name of the quartus project
PROJECT_NAME=tse_tutorial
SOPC_FILE=../quartus/$(PROJECT_NAME).sopcinfo

BSP_SETTINGS_FILE=./settings.bsp
BSP_DIR=./bsp
QUARTUS_PROJECT_DIR=../quartus
APPLICATION_BUILD_DIR=./build
APPLICATION_MAKEFILE=$(APPLICATION_BUILD_DIR)/Makefile 
ELF_FILE=$(APPLICATION_BUILD_DIR)/$(PROJECT_NAME).elf

#info: The application makefile automatically runs the bsp makefile
SRC_DIR=./src
NIOS2_APP_GEN_ARGS=--elf-name ${PROJECT_NAME}.elf --set APP_CFLAGS_OPTIMIZATION -Os --set OBJDUMP_INCLUDE_SOURCE 1 --src-rdir ${SRC_DIR}


all: $(ELF_FILE) 

$(APPLICATION_MAKEFILE): $(BSP_DIR) src/*
	nios2-app-generate-makefile --app-dir ${APPLICATION_BUILD_DIR} --bsp-dir ${BSP_DIR} --set QUARTUS_PROJECT_DIR=${QUARTUS_PROJECT_DIR} ${NIOS2_APP_GEN_ARGS}
	

run: $(ELF_FILE) 
	nios2-download -g $(ELF_FILE) && nios2-terminal

download: 
	nios2-download -g $(ELF_FILE)

term:
	nios2-terminal

edit_bsp:
	nios2-bsp-editor &

$(ELF_FILE): $(APPLICATION_MAKEFILE)
	make -C $(APPLICATION_BUILD_DIR)

$(BSP_DIR): $(SOPC_FILE) $(BSP_SETTINGS_FILE)
	mkdir -p $(BSP_DIR)
	nios2-bsp-update-settings --settings $(BSP_SETTINGS_FILE) --sopc $(SOPC_FILE)
	nios2-bsp-generate-files --settings $(BSP_SETTINGS_FILE) --bsp-dir $(BSP_DIR)


clean:
	rm -rf $(BSP_DIR)
	rm -rf $(APPLICATION_BUILD_DIR)


.PHONY: bsp_edit
.PHONY: term
.PHONY: download
.PHONY: run





PROJECT_NAME=tse_tutorial

LOG_FILE=BUILD_$(shell date '+%d.%m.%y-%H_%M_%S').log
PROJECT_DIR=$(shell pwd)
QSYS_OUTPUT_DIR=$(PROJECT_DIR)/$(PROJECT_NAME)
SOPC_INFO_FILE=$(PROJECT_NAME).sopcinfo
QSYS_FILE=$(PROJECT_NAME).qsys

SOF_FILE=output_files/$(PROJECT_NAME)_time_limited.sof

all: $(SOF_FILE)

quartus: $(SOF_FILE)

# starts the quartus GUI and loads the quartus project
quartus_gui:
	quartus --64bit $(PROJECT_NAME).qpf &

# starts the qsys GUI and loads the qsys project
qsys_gui:
	qsys-edit $(PROJECT_NAME).qsys &


$(SOF_FILE): $(QSYS_FILE) $(PROJECT_NAME).qsf $(PROJECT_NAME).qpf
	@echo ""
	@echo "---------------------------------------------" >> $(LOG_FILE)
	@echo "-                  QUARTUS                  -" >> $(LOG_FILE)
	@echo "---------------------------------------------" >> $(LOG_FILE)
	quartus_sh --flow compile $(PROJECT_NAME) 2>&1 | tee -a $(LOG_FILE) 
	
download:
	quartus_pgm -m jtag -o"p;$(SOF_FILE)"
	
	
clean:
	rm -f $(PROJECT_NAME).sopcinfo
	rm -f $(PROJECT_NAME).html
	rm -f $(PROJECT_NAME).cmp
	rm -f *.rpt
	rm -f *.qws
	rm -fr $(QSYS_OUTPUT_DIR)
	rm -fr output_files
	rm -fr db
	rm -f *.bsf
	rm -f *.dpf
	rm -f *.srf
	rm -fr incremental_db
	rm -f *.jdi
	rm -f *.html
	rm -f *.smsg
	rm -f *.summary
	rm -f *.qdf
	rm -f *.qws


.PHONY: qsys_gui
.PHONY: quartus
.PHONY: quartus_gui
.PHONY: download
.PHONY: clean


# If you want to manually run the qsys system generation process you can use 
# the following rules.

#DEVICE_FAMILY="Cyclone IV E"
#DEVICE=EP4CE22F17C6
#DEVICE_SPEEDGRADE=6 

#qsys: $(SOPC_INFO_FILE)
#.PHONY: qsys

# QSYS creates the synthesis directory and the sopcinfo file
# The sopcinfo file is used to generate the board support package (bsp) for the 
# software. It is not required for the quartus design flow. However here, we use
# it as target for the qsys rule. 
#$(SOPC_INFO_FILE): $(QSYS_FILE)
	@echo "---------------------------------------------" >> $(LOG_FILE)
	@echo "-                 QSYS                      -" >> $(LOG_FILE)
	@echo "---------------------------------------------" >> $(LOG_FILE)
	ip-generate \
	--project-directory=$(PROJECT_DIR)   \
	--output-directory=$(QSYS_OUTPUT_DIR)     \
	--report-file=bsf:$(PROJECT_DIR)/$(PROJECT_NAME).bsf \
	--system-info=DEVICE_FAMILY=$(DEVICE_FAMILY) \
	--system-info=DEVICE=$(DEVICE) \
	--system-info=DEVICE_SPEEDGRADE=$(DEVICE_SPEEDGRADE) \
	--component-file=$(PROJECT_DIR)/$(PROJECT_NAME).qsys 2>&1 | tee -a $(LOG_FILE) 
	ip-generate \
	--project-directory=$(PROJECT_DIR) \
	--output-directory=$(SYNTHESIS_DIR) \
	--file-set=QUARTUS_SYNTH \
	--report-file=sopcinfo:$(PROJECT_DIR)/$(PROJECT_NAME).sopcinfo \
	--report-file=html:$(PROJECT_DIR)/$(PROJECT_NAME).html \
	--report-file=qip:$(SYNTHESIS_DIR)/$(PROJECT_NAME).qip \
	--report-file=cmp:$(PROJECT_DIR)/$(PROJECT_NAME).cmp \
	--system-info=DEVICE_FAMILY=$(DEVICE_FAMILY) \
	--system-info=DEVICE=$(DEVICE) \
	--system-info=DEVICE_SPEEDGRADE=$(DEVICE_SPEEDGRADE) \
	--component-file=$(PROJECT_DIR)/$(PROJECT_NAME).qsys 2>&1 | tee -a $(LOG_FILE) 

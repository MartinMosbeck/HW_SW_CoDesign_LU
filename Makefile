

all:
	make -C quartus
	make -C software
	make -C download
	make -C run


clean:
	make -C quartus clean
	make -C software clean



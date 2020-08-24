ROSE_INSTALL=/home/liao6/workspace/rose/2020-03-24_00-33-52_-0700/installDebug
# the path to the outline program
TOOL=$(ROSE_INSTALL)/bin/outline

rose_ft_cfftz.c:ft_cfftz.c
	$(TOOL) -c -I$(ROSE_INSTALL)/include -rose:outline:select_omp_loop -rose:outline:use_dlopen -rose:outline:copy_orig_file -rose:unparseHeaderFilesRootFolder . ft_cfftz.c

C_FLAGS=-I. -g 
C_LINK_FLAGS= -Wl,--export-dynamic -g -ldl -lm # calling dlopen() etc.

C_LIB_FLAGS=-I. -g -fPIC
C_LIB_LINK_FLAGS= -g -shared

# the main function
#------------------------------
rose_ft_cfftz.o: rose_ft_cfftz.c
	gcc ${C_FLAGS} -c $<
# supportive lib
autotuning_lib.o: autotuning_lib.c
	gcc ${C_FLAGS} -c $<

# shared lib	
#------------------------------
# the lib with outlined function, not quite right, copy origin file!!	
rose_ft_cfftz_lib.o: rose_ft_cfftz_lib.c
	gcc ${C_LIB_FLAGS} -c $<

#rose_ft_cfftz_lib.so: ft_cfftz_shared.o rose_ft_cfftz_lib.o	
rose_ft_cfftz_lib.so:rose_ft_cfftz_lib.o	
	gcc ${C_LIB_LINK_FLAGS} $^ -o rose_ft_cfftz_lib.so
	cp rose_ft_cfftz_lib.so /tmp/.

# build the executable from the transformed file with main() 
#------------------------------
# must not use -shared -fPIC, or seg fault!
a.out:rose_ft_cfftz.o rose_ft_cfftz_lib.so autotuning_lib.o
	gcc -o $@ rose_ft_cfftz.o autotuning_lib.o ${C_LINK_FLAGS}

check:a.out

run:a.out
	./a.out
check_PROGRAM: a.out

TESTS = $(check_PROGRAM)

clean:
	rm -rf *.out *.o *.so /tmp/rose_ft_cfftz_lib.so rose_*.c

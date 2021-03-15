# Project Resources
kProjRootDir := $(realpath ../)
kInstallPrefix := /usr

kCSrcDir := ${kProjRootDir}/src/sw
kIncludeDirs := ${kCSrcDir}
kSystemdFileDir := ${kProjRootDir}/src/sw
kBuildDir := ${kProjRootDir}/build/xvc_server_sw

kTarget := xvc_server

kCSrcFiless := ${kTarget}.c
kSystemdFile := ${kTarget}d.service

## Evaluate Project Resources
c_srcs := $(foreach csrcs, ${kCSrcFiless}, $(addprefix ${kCSrcDir}/, ${csrcs}) )
systemd_src_file := ${kSystemdFileDir}/${kSystemdFile}
objs := ${kBuildDir}/${kTarget}.o
target := ${kBuildDir}/${kTarget}
systemd_out_path := ${kBuildDir}/${kSystemdFile}
bin_install_dir := ${kInstallPrefix}/bin
sd_install_dir := ${kInstallPrefix}/lib/systemd/system

# Features of Compiler and linker
CC := /usr/bin/arm-linux-gnueabihf-gcc
CFLAGS := -std=gnu11 -Wall
DEBUGFLGAS := -g
RELEASEFLAG := -O2 -D RELEASE
LDFLGAS := -static
INCLUDES := $(foreach i_dirs, ${kIncludeDirs}, $(addprefix -I, ${i_dirs}) )

# Process compilations
.PHONY : debug, release, linking, debug_compile, release_compile,\
	create_odir, clean, cp_sd,\
	install, uninstall

default: debug
debug: create_odir debug_compile linking cp_sd
release: create_odir release_compile linking cp_sd

create_odir:
	mkdir -p ${kBuildDir} ${kBuildDir}

linking: ${objs}
	${CC} ${LDFLGAS} ${objs} -o ${target}

debug_compile: ${c_srcs}
	${CC} ${CFLAGS} ${DEBUGFLGAS} ${INCLUDES} -c ${c_srcs} -o ${objs}

release_compile: ${c_srcs}
	${CC} ${CFLAGS} ${RELEASEFLAG} ${INCLUDES} -c ${c_srcs} -o ${objs}

cp_sd:
	cp -f ${systemd_src_file} ${systemd_out_path}

clean:
	rm -rf ${kBuildDir}

install: cp_sd, linking
	install -d ${bin_install_dir}
	install -m 744 ${target} ${bin_install_dir}
	install -d ${sd_install_dir}
	install -m 744 ${systemd_out_path} ${sd_install_dir}

uninstall:
	rm -f ${bin_install_dir}/${kTarget}
	rm -f ${sd_install_dir}/${kSystemdFile}

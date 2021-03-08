cmake_minimum_required(VERSION  3.8)
set(kProjName xvc_server)
project(${kProjName})

set(kCSrcs 
	${kCSrcs}
	xvc_server.c
)

set(kSystemdSrcs 
	${kSystemdSrcs}
	xvc_server.service
)

add_executable(
	${kProjName}
	${kCSrcs}
)

set_target_properties( 
  ${kProjName}
  	PROPERTIES
      C_STANDARD 11
      C_STANDARD_REQUIRED ON
      C_EXTENSIONS OFF  # use Std.C instead of GNU.C 

target_link_libraries(
	${kProjName}
)


set(prj boost)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
#option(XP_USE_LATEST_BOOST "build with boost 1.58.0 instead of 1.57.0" OFF)
#if(XP_USE_LATEST_BOOST)
#  set(BOOST_VER 1.58.0)
#else()
  set(BOOST_VER 1.57.0)
#endif()
if(NOT DEFINED Boost_LIBS)
  set(Boost_LIBS # dependency order
    log_setup # depends on log, regex, filesystem, thread, system (m, pthread)
    ######
    coroutine # depends on thread, context (m)
    log # depends on filesystem, thread, system (rt, pthread, m)
    timer # depends on chrono (m)
    ######
    chrono # depends on system (rt, pthread, m)
    filesystem # depends on system (pthread, m)
    graph # depends on regex (m)
    random # depends on system (pthread, m)
    thread # depends on system (rt, pthread, m)
    wserialization # depends on serialization (m)
    ######
    atomic
    container # depends on (pthread)
    context
    date_time # depends on (m)
    exception
    iostreams # depends on (z, bz2, pthread, m)
    program_options # depends on (m)
    regex # depends on (pthread, m)
    serialization # depends on (m)
    signals # depends on (m)
    system # depends on (m)
    test_exec_monitor
    unit_test_framework # depends on (pthread, m)
    )
  if(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "SunOS")
    list(APPEND Boost_LIBS
      python # depends on (m)
    )
  endif()
  # NOTE: determined boost library dependency order by building boost on linux
  # with link=shared and runtime-link=shared and using ldd
endif()
list(FIND Boost_LIBS iostreams idx)
if(NOT ${idx} EQUAL -1)
  xpGetExtern(dontcare zlibBinary PRIVATE zlib)
  xpGetExtern(dontcare bzip2Binary PRIVATE bzip2)
endif()
unset(Boost_INCLUDE_DIR CACHE)
unset(Boost_LIBRARY_DIR CACHE)
foreach(lib ${Boost_LIBS})
  string(TOUPPER ${lib} UPPERLIB)
  unset(Boost_${UPPERLIB}_LIBRARY_DEBUG CACHE)
  unset(Boost_${UPPERLIB}_LIBRARY_RELEASE CACHE)
endforeach()
string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1.\\2" BOOST_VER2 ${BOOST_VER})
set(Boost_ADDITIONAL_VERSIONS ${BOOST_VER} ${BOOST_VER2})
if(UNIX)
  if(DEFINED zlibBinary AND DEFINED bzip2Binary)
    set(syslibs $<TARGET_FILE:${zlibBinary}> $<TARGET_FILE:${bzip2Binary}>)
  endif()
  include(CheckLibraryExists)
  function(checkLibraryConcat lib symbol liblist)
    string(TOUPPER ${lib} LIB)
    check_library_exists("${lib}" "${symbol}" "" XP_BOOST_HAS_${LIB})
    if(XP_BOOST_HAS_${LIB})
      list(APPEND ${liblist} ${lib})
      set(${liblist} ${${liblist}} PARENT_SCOPE)
    endif()
  endfunction()
  checkLibraryConcat(m pow syslibs)
  checkLibraryConcat(pthread pthread_create syslibs)
  checkLibraryConcat(rt shm_open syslibs)
  # see FindBoost.cmake for details on the following variables
  set(Boost_FIND_QUIETLY TRUE)
  set(Boost_NO_SYSTEM_PATHS TRUE)
  set(Boost_USE_STATIC_LIBS ON)
  set(Boost_USE_MULTITHREADED ON)
  set(Boost_USE_STATIC_RUNTIME ON)
  #set(Boost_DEBUG TRUE) # enable debugging output of FindBoost.cmake
  #set(Boost_DETAILED_FAILURE_MSG) # output detailed information
  set(BOOST_ROOT ${XP_ROOTDIR})
  # TODO: remove the following conditional once FindBoost.cmake detects clang
  if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    include(${CMAKE_CURRENT_LIST_DIR}/xpfunmac.cmake)
    xpGetCompilerPrefix(_boost_COMPILER)
    set(_boost_COMPILER "-${_boost_COMPILER}")
  endif()
  find_package(Boost ${BOOST_VER} REQUIRED COMPONENTS ${Boost_LIBS})
  set(${PRJ}_FOUND ${Boost_FOUND})
  set(${PRJ}_INCLUDE_DIR ${Boost_INCLUDE_DIRS})
  set(${PRJ}_LIBRARIES ${Boost_LIBRARIES} ${syslibs})
  set(reqVars ${PRJ}_INCLUDE_DIR ${PRJ}_LIBRARIES)
else()
  string(REPLACE "." "_" VER_ ${BOOST_VER2})
  set(${PRJ}_INCLUDE_DIR ${XP_ROOTDIR}/include/boost-${VER_})
  if(EXISTS ${${PRJ}_INCLUDE_DIR} AND IS_DIRECTORY ${${PRJ}_INCLUDE_DIR})
    set(${PRJ}_FOUND TRUE)
  else()
    set(${PRJ}_FOUND FALSE)
  endif()
  link_directories(${XP_ROOTDIR}/lib)
  set(reqVars ${PRJ}_INCLUDE_DIR)
  if(DEFINED zlibBinary AND DEFINED bzip2Binary)
    add_definitions(
      -DBOOST_ZLIB_BINARY=$<TARGET_FILE:${zlibBinary}>
      -DBOOST_BZIP2_BINARY=$<TARGET_FILE:${bzip2Binary}>
      )
  endif()
endif()
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})

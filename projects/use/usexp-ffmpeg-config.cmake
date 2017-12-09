# FFMPEG_FOUND - FFmpeg was found
# FFMPEG_INCLUDE_DIR - the FFmpeg include directories
# FFMPEG_LIBRARIES - the FFmpeg libraries
# FFMPEG_DLLS - the FFmpeg shared objects (dll, so)
xpGetPkgVar(OpenH264 DLLS) # sets OPENH264_DLLS
set(prj ffmpeg)
# this file (-config) installed to share/cmake
get_filename_component(XP_ROOTDIR ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE)
get_filename_component(XP_ROOTDIR ${XP_ROOTDIR} ABSOLUTE) # remove relative parts
string(TOUPPER ${prj} PRJ)
set(ver _@VER@)
set(verDir /${prj}${ver})
unset(${PRJ}_INCLUDE_DIR CACHE)
find_path(${PRJ}_INCLUDE_DIR ffmpeg/libavcodec/avcodec.h PATHS ${XP_ROOTDIR}/include${verDir} NO_DEFAULT_PATH)
list(APPEND ${PRJ}_INCLUDE_DIR ${XP_ROOTDIR}/include${verDir}/ffmpeg) # for internal header includes
set(reqVars ${PRJ}_INCLUDE_DIR)
if(WIN32)
  set(${PRJ}_LIBRARIES
    avcodec${ver}.lib
    avdevice${ver}.lib
    avfilter${ver}.lib
    avformat${ver}.lib
    avutil${ver}.lib
    swresample${ver}.lib
    swscale${ver}.lib
    )
  link_directories(${XP_ROOTDIR}/lib)
  set(${PRJ}_DLLS
    ${XP_ROOTDIR}/bin${verDir}/avcodec-56.dll
    ${XP_ROOTDIR}/bin${verDir}/avdevice-56.dll
    ${XP_ROOTDIR}/bin${verDir}/avfilter-5.dll
    ${XP_ROOTDIR}/bin${verDir}/avformat-56.dll
    ${XP_ROOTDIR}/bin${verDir}/avutil-54.dll
    ${XP_ROOTDIR}/bin${verDir}/swresample-1.dll
    ${XP_ROOTDIR}/bin${verDir}/swscale-3.dll
    )
  list(APPEND reqVars ${PRJ}_LIBRARIES ${PRJ}_DLLS)
else()
  set(${PRJ}_LIBRARIES
    avcodec${ver}
    avdevice${ver}
    avfilter${ver}
    avformat${ver}
    avutil${ver}
    swresample${ver}
    swscale${ver}
    z # TODO this shouldn't be hard-coded
    # https://stackoverflow.com/questions/27366433/linking-libavcodec-and-libavformat-undefined-references
    ${OPENH264_DLLS}
    )
  link_directories(${XP_ROOTDIR}/lib)
  set(${PRJ}_DLLS ${OPENH264_DLLS})
  list(APPEND reqVars ${PRJ}_LIBRARIES ${PRJ}_DLLS)
endif()
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${prj} REQUIRED_VARS ${reqVars})
mark_as_advanced(${reqVars})
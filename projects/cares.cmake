# cares
xpProOption(cares DBG)
set(VER 1.10.0)
string(REPLACE "." "_" VER_ ${VER})
set(REPO github.com/c-ares/c-ares)
set(FORK github.com/smanders/c-ares)
set(PRO_CARES
  NAME cares
  WEB "c-ares" http://c-ares.haxx.se/ "c-ares website"
  LICENSE "open" http://c-ares.haxx.se/license.html "c-ares license: MIT license"
  DESC "C library for asynchronous DNS requests (including name resolves)"
  REPO "repo" https://${REPO} "c-ares repo on github"
  GRAPH GRAPH_LABEL "c-ares"
  VER ${VER}
  GIT_ORIGIN git://${FORK}.git
  GIT_UPSTREAM git://${REPO}.git
  GIT_TAG xp-${VER_} # what to 'git checkout'
  GIT_REF cares-${VER_} # create patch from this tag to 'git checkout'
  DLURL http://c-ares.haxx.se/download/c-ares-${VER}.tar.gz
  DLMD5 1196067641411a75d3cbebe074fd36d8
  PATCH ${PATCH_DIR}/cares.patch
  DIFF https://${FORK}/compare/c-ares:
  DEPS_FUNC build_cares
  )
########################################
function(build_cares)
  if(NOT (XP_DEFAULT OR XP_PRO_CARES))
    return()
  endif()
  xpGetArgValue(${PRO_CARES} ARG VER VALUE VER)
  configure_file(${PRO_DIR}/use/usexp-cares-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
  set(XP_CONFIGURE
    -DXP_INSTALL_DIRS:BOOL=ON
    -DXP_NAMESPACE:STRING=xpro
    -DCMAKE_INSTALL_LIBDIR=lib # without this *some* platforms (RHEL, but not Ubuntu) install to lib64
    -DCARES_VER:STRING=${VER}
    )
  xpCmakeBuild(cares "" "${XP_CONFIGURE}" caresTargets)
  if(ARGN)
    set(${ARGN} "${caresTargets}" PARENT_SCOPE)
  endif()
endfunction()

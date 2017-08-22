# jxrlib
xpProOption(jxrlib)
set(JXRVER 15.08)
set(REPO https://github.com/smanders/jxrlib)
set(PRO_JXRLIB
  NAME jxrlib
  WEB "jxrlib" https://jxrlib.codeplex.com/ "jxrlib project hosted on CodePlex"
  LICENSE "open" https://jxrlib.codeplex.com/license "New BSD License (BSD)"
  DESC "open source implementation of the jpegxr image format standard"
  REPO "repo" ${REPO} "forked jxrlib repo on github"
  VER ${JXRVER}
  GIT_ORIGINAL_UPSTREAM https://git01.codeplex.com/jxrlib # CodePlex is shutting down!
  GIT_UPSTREAM git://github.com/c0nk/jxrlib.git
  GIT_ORIGIN git://github.com/smanders/jxrlib.git
  GIT_TAG xp${JXRVER} # what to 'git checkout'
  GIT_REF v${JXRVER} # create patch from this tag to 'git checkout'
  # NOTE: the download from codeplex is CR/LF, the repo is LF
  #DLURL https://jxrlib.codeplex.com/downloads/get/685250
  DLURL ${REPO}/archive/v${JXRVER}.tar.gz
  DLMD5 93822c8ba22b44ee7d1a4810e2a9468b
  DLNAME jxrlib-v${JXRVER}.tar.gz
  PATCH ${PATCH_DIR}/jxrlib.patch
  DIFF ${REPO}/compare/
  )
########################################
function(build_jxrlib)
  if(NOT (XP_DEFAULT OR XP_PRO_JXRLIB))
    return()
  endif()
  configure_file(${PRO_DIR}/use/usexp-jxrlib-config.cmake ${STAGE_DIR}/share/cmake/
    @ONLY NEWLINE_STYLE LF
    )
  xpCmakeBuild(jxrlib "" "-DJXR_VER=${JXRVER}")
endfunction()

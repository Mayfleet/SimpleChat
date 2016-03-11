# Install main executable

INSTALL(
    TARGETS ${SIMPLECHAT_TARGET}
    BUNDLE DESTINATION .
    RUNTIME DESTINATION .
)

# Setup target properties

SET_TARGET_PROPERTIES(
    ${SIMPLECHAT_TARGET}
    PROPERTIES LINK_FLAGS "/MANIFESTDEPENDENCY:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' publicKeyToken='6595b64144ccf1df' language='*' processorArchitecture='*'\""
)

# Install Microsoft Visual Studio 2010 CRT libraries

FIND_PACKAGE(VC100CRT REQUIRED)

INSTALL(
    FILES ${VC100CRT_LIBRARIES}
    DESTINATION .
)

# Configure target variables

SET(SIMPLECHAT_EXECUTABLE "${SIMPLECHAT_TARGET}.exe")
SET(SIMPLECHAT_QT_PLUGINS_DEST_DIR "Plugins")
SET(SIMPLECHAT_SEARCH_PATHS "${QT_BINARY_DIR}")

# Install Qt conf

INSTALL(FILES "qt.conf" DESTINATION . )

# Install plugins
# Platforms plugins

INSTALL(
    DIRECTORY "${QT_PLUGINS_DIR}/platforms"
    DESTINATION ${SIMPLECHAT_QT_PLUGINS_DEST_DIR}
    FILES_MATCHING PATTERN "*windows.dll"
)

# Audio plugins

INSTALL(
    DIRECTORY "${QT_PLUGINS_DIR}/audio"
    DESTINATION "${SIMPLECHAT_QT_PLUGINS_DEST_DIR}"
    FILES_MATCHING PATTERN "*windows.dll"
)

# Install bundle fixup code

INSTALL(
    CODE "INCLUDE(BundleUtilities)
          FILE(
              GLOB_RECURSE SIMPLECHAT_QT_PLUGINS
              \"\${CMAKE_INSTALL_PREFIX}/${SIMPLECHAT_QT_PLUGINS_DEST_DIR}/*${CMAKE_SHARED_LIBRARY_SUFFIX}\"
          )

          SET(SIMPLECHAT_APPLICATION \"\${CMAKE_INSTALL_PREFIX}/${SIMPLECHAT_EXECUTABLE}\")
          SET(BU_CHMOD_BUNDLE_ITEMS TRUE) # This ensures that any bundle items are made user writable
          FIXUP_BUNDLE(\"\${SIMPLECHAT_APPLICATION}\" \"\${SIMPLECHAT_QT_PLUGINS}\" \"${SIMPLECHAT_SEARCH_PATHS}\")
          VERIFY_APP(\"\${SIMPLECHAT_APPLICATION}\")"
)

# Configure deployment

SET(CPACK_GENERATOR "ZIP")
SET(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION_LONG}-${TARGET_PLATFORM}")

INCLUDE(CPack)


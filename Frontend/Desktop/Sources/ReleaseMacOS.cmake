# Install main executable

INSTALL(
    TARGETS ${SIMPLECHAT_TARGET}
    BUNDLE DESTINATION .
    RUNTIME DESTINATION .
)

# Configure bundle

SET(MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}")
SET(MACOSX_BUNDLE_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}")
SET(MACOSX_BUNDLE_INFO_STRING "${PROJECT_NAME} ${VERSION_MAJOR}.${VERSION_MINOR}")
SET(MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_NAME} ${VERSION_MAJOR}.${VERSION_MINOR}")
SET(MACOSX_BUNDLE_LONG_VERSION_STRING "${PROJECT_NAME} - Version ${VERSION_MAJOR}.${VERSION_MINOR}")
SET(MACOSX_BUNDLE_GUI_IDENTIFIER "com.mayfleet.${PROJECT_NAME_LOWERCASE}")
SET(MACOSX_BUNDLE_ICON_FILE ${SIMPLECHAT_ICON})

# Configure target variables

SET(SIMPLECHAT_EXECUTABLE "${SIMPLECHAT_TARGET}.app")
SET(SIMPLECHAT_QT_PLUGINS_DEST_DIR "${SIMPLECHAT_EXECUTABLE}/Contents/Plugins")
SET(SIMPLECHAT_SEARCH_PATHS "${QT_LIBRARY_DIR}")

# Install Qt conf

INSTALL(FILES "qt.conf" DESTINATION "${SIMPLECHAT_EXECUTABLE}/Contents/Resources")

# Install plugins
# Platforms plugins

INSTALL(
    DIRECTORY "${QT_PLUGINS_DIR}/platforms"
    DESTINATION ${SIMPLECHAT_QT_PLUGINS_DEST_DIR}
    FILES_MATCHING PATTERN "*cocoa.dylib"
)

# Install code for bundle fixup

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
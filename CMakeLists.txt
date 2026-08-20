cmake_minimum_required(VERSION 3.14.0)
project(proofcheck VERSION 2.0)

find_package(Threads REQUIRED)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SIDESTEP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/sidestep")

# Re-hash every release source file against MANIFEST.sha256 and refuse to
# build if any of them don't match. This is a real custom TARGET (no
# OUTPUT), so CMake/Make/Ninja always consider it out of date and rerun
# it on every build invocation -- not just once at the first `cmake`
# configure -- so a source file edited after checkout is still caught
# before it gets compiled. proofcheck depends on it, so no compilation
# can start until it passes.
add_custom_target(verify_sources ALL
  COMMAND ${CMAKE_COMMAND}
          -DSRC_ROOT=${CMAKE_CURRENT_SOURCE_DIR}
          -DMANIFEST=${CMAKE_CURRENT_SOURCE_DIR}/MANIFEST.sha256
          -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/verify_manifest.cmake
  COMMENT "Verifying source files against MANIFEST.sha256 before compiling"
  VERBATIM)

add_executable(proofcheck
  verify.cpp
  ${SIDESTEP_DIR}/sidestep.cpp
  ${SIDESTEP_DIR}/terms.cpp
  ${SIDESTEP_DIR}/unify.cpp
  ${SIDESTEP_DIR}/parse.cpp
  ${SIDESTEP_DIR}/rules.cpp
  ${SIDESTEP_DIR}/sat.cpp)

target_include_directories(proofcheck PRIVATE ${SIDESTEP_DIR})
target_link_libraries(proofcheck Threads::Threads)
add_dependencies(proofcheck verify_sources)

set_target_properties(proofcheck PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON)

# The license absolutely limits distribution of the binary without the
# license (Condition 1: every redistribution of an Unmodified Binary
# must be accompanied by the complete license text). This is not a
# packaging nicety -- proofcheck itself checks for LICENSE next to its
# own executable at startup and refuses to run if it's missing or
# altered (see check_license_integrity() in verify.cpp). Copying it
# here, automatically, on every build, means that check can never be
# defeated by simply forgetting a manual step.
add_custom_command(TARGET proofcheck POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
          "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE"
          "$<TARGET_FILE_DIR:proofcheck>/LICENSE"
  COMMENT "Copying LICENSE next to the proofcheck binary (required -- see verify.cpp's license-integrity check)")

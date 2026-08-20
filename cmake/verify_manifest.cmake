# Verifies every file listed in MANIFEST.sha256 against its recorded
# SHA-256 hash. Run via an always-out-of-date custom target (see
# CMakeLists.txt) so this re-checks on every build invocation, not just
# once at configure time -- a source file edited after configure must
# still be caught before it gets compiled.
#
# Invoked as: cmake -DSRC_ROOT=... -DMANIFEST=... -P verify_manifest.cmake

if(NOT DEFINED SRC_ROOT)
  message(FATAL_ERROR "verify_manifest.cmake: SRC_ROOT not set")
endif()
if(NOT DEFINED MANIFEST)
  message(FATAL_ERROR "verify_manifest.cmake: MANIFEST not set")
endif()
if(NOT EXISTS "${MANIFEST}")
  message(FATAL_ERROR "source manifest not found: ${MANIFEST}")
endif()

file(STRINGS "${MANIFEST}" MANIFEST_LINES)

set(MISMATCHES "")
set(CHECKED 0)

foreach(line IN LISTS MANIFEST_LINES)
  string(STRIP "${line}" line)
  if(line STREQUAL "")
    continue()
  endif()

  # Format: "<64-hex-char sha256>  <relpath>" (sha256sum-compatible).
  string(REGEX MATCH "^([0-9a-f]+)[ \t]+(.+)$" m "${line}")
  if(NOT m)
    message(FATAL_ERROR "malformed manifest line in ${MANIFEST}: ${line}")
  endif()
  set(expected "${CMAKE_MATCH_1}")
  set(relpath "${CMAKE_MATCH_2}")
  string(LENGTH "${expected}" expected_len)
  if(NOT expected_len EQUAL 64)
    message(FATAL_ERROR "malformed manifest line in ${MANIFEST} (hash is not 64 hex chars): ${line}")
  endif()

  set(full "${SRC_ROOT}/${relpath}")
  if(NOT EXISTS "${full}")
    list(APPEND MISMATCHES "MISSING: ${relpath} (listed in manifest, not found on disk)")
    continue()
  endif()

  file(SHA256 "${full}" actual)
  if(NOT actual STREQUAL expected)
    list(APPEND MISMATCHES "MODIFIED: ${relpath}  (expected ${expected}, got ${actual})")
  endif()
  math(EXPR CHECKED "${CHECKED}+1")
endforeach()

if(MISMATCHES)
  string(REPLACE ";" "\n  " MISMATCH_TEXT "${MISMATCHES}")
  message(FATAL_ERROR
    "source integrity check FAILED -- refusing to compile.\n"
    "  ${MISMATCH_TEXT}\n"
    "One or more release source files do not match MANIFEST.sha256. This "
    "means the checked-out source no longer matches what the release was "
    "built from. Re-clone the repository or investigate before building.")
endif()

message(STATUS "source integrity check passed (${CHECKED} files verified against MANIFEST.sha256)")

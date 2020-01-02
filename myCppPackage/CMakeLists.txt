cmake_minimum_required(VERSION 2.8.12)
project(myCppPackage)

# Set include directories

# Set source directory
set(SOURCE_DIR "src/myCppPackage")

# Tell CMake that headers are also in SOURCE_DIR
include_directories(${SOURCE_DIR})
set(SOURCES "${SOURCE_DIR}/hello_world_cpp.cpp")

# Generate Python module
add_subdirectory(lib/pybind11)
pybind11_add_module(hello_world_cpp ${SOURCES})

# Generate C++ Tests
SET(TEST_DIR "tests")
SET(TESTS ${SOURCES}
    "${TEST_DIR}/test_init.cpp"
    "${TEST_DIR}/test_hello_world.cpp"
)

find_package(PythonLibs REQUIRED)

include_directories(
    ${PYTHON_INCLUDE_DIRS}
    lib
    lib/pybind11/include
)

# Change the build directory for these to the tests directory

SET(PROJECT_TEST "${PROJECT_NAME}_test")
add_executable(${PROJECT_TEST} ${TESTS})
message("Begin message")
message("${PROJECT_SOURCE_DIR}/${TEST_DIR}") 
set_target_properties(
    ${PROJECT_TEST} 
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE 
    "${PROJECT_SOURCE_DIR}/${TEST_DIR}"
)
target_link_libraries(${PROJECT_TEST} ${PYTHON_LIBRARIES})


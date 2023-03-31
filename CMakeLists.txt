cmake_minimum_required(VERSION 3.0)
project(Compilers)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${Compilers_SOURCE_DIR}/bin)

set(HEADERS
        ${Compilers_SOURCE_DIR}/driver.hh
        ${Compilers_SOURCE_DIR}/parser.hh)

BISON_TARGET(MyParser parser.y
        ${Compilers_SOURCE_DIR}/parser.cpp
        COMPILE_FLAGS --graph
        DEFINES_FILE ${Compilers_SOURCE_DIR}/parser.hh)

FLEX_TARGET(MyScanner
        scanner.l
        ${Compilers_SOURCE_DIR}/scanner.cpp)

ADD_FLEX_BISON_DEPENDENCY(MyScanner MyParser)

add_executable(02-ParserExample main.cpp driver.cpp
        ${BISON_MyParser_OUTPUTS}
        ${FLEX_MyScanner_OUTPUTS})

target_include_directories(02-ParserExample PRIVATE ${Compilers_SOURCE_DIR})


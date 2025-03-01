cmake_minimum_required(VERSION 3.18.1)
project(enhanced-root-hiding)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(${PROJECT_NAME} SHARED
        main.cpp)

target_link_libraries(${PROJECT_NAME}
        log)

set_target_properties(${PROJECT_NAME} PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        LINK_FLAGS "-ffixed-x18 -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/symbol.map")

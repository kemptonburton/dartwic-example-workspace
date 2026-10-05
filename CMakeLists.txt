cmake_minimum_required(VERSION 3.23)
project(dartwic_example_workspace LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# A DARTWIC checkout uses its sibling example plugin. A standalone clone fetches
# the same public source at a locked commit; no private checkout is required.
set(DARTWIC_EXAMPLE_PLUGIN_SOURCE "" CACHE PATH "Local dartwic-example-plugin checkout")
if(NOT DARTWIC_EXAMPLE_PLUGIN_SOURCE)
    set(local_plugin "${CMAKE_CURRENT_SOURCE_DIR}/../../sdk/dartwic-example-plugin")
    if(EXISTS "${local_plugin}/engine/src/example_transport.cpp")
        set(DARTWIC_EXAMPLE_PLUGIN_SOURCE "${local_plugin}")
    else()
        include(FetchContent)
        FetchContent_Declare(example_plugin
            GIT_REPOSITORY https://github.com/kemptonburton/dartwic-example-plugin.git
            GIT_TAG 5f3286ffe403ba05e110315bb974c7c6ef8fd70b)
        FetchContent_GetProperties(example_plugin)
        if(NOT example_plugin_POPULATED)
            FetchContent_Populate(example_plugin)
        endif()
        set(DARTWIC_EXAMPLE_PLUGIN_SOURCE "${example_plugin_SOURCE_DIR}")
    endif()
endif()

set(plugin "${DARTWIC_EXAMPLE_PLUGIN_SOURCE}")
if(NOT EXISTS "${plugin}/engine/src/example_transport.cpp")
    message(FATAL_ERROR "DARTWIC_EXAMPLE_PLUGIN_SOURCE must point to dartwic-example-plugin")
endif()

add_subdirectory("${plugin}/vendor/messaging" "${CMAKE_CURRENT_BINARY_DIR}/vendor/messaging")
add_subdirectory("${plugin}/vendor/peer" "${CMAKE_CURRENT_BINARY_DIR}/vendor/peer")
add_subdirectory("${plugin}/vendor/engine-protocol" "${CMAKE_CURRENT_BINARY_DIR}/vendor/engine-protocol")
find_package(nlohmann_json CONFIG REQUIRED)
find_package(cppzmq CONFIG REQUIRED)

add_executable(rocket-flight-peer
    flight-computer/main.cpp
    "${plugin}/engine/src/example_transport.cpp")
target_include_directories(rocket-flight-peer PRIVATE "${plugin}/engine/include")
target_link_libraries(rocket-flight-peer PRIVATE
    TEMPEST::Peer DARTWIC::EngineProtocol cppzmq nlohmann_json::nlohmann_json)

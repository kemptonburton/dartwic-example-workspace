cmake_minimum_required(VERSION 3.23)
project(dartwic_example_workspace VERSION 2.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# A DARTWIC checkout uses its sibling example plugin. A standalone clone fetches
# the same public source at a locked commit; no private checkout is required.
set(DARTWIC_EXAMPLE_PLUGIN_SOURCE "" CACHE PATH "Local dartwic-example-plugin checkout")
if(NOT DARTWIC_EXAMPLE_PLUGIN_SOURCE)
    set(local_plugin "${CMAKE_CURRENT_SOURCE_DIR}/../../../plugins/dartwic-example-plugin")
    if(EXISTS "${local_plugin}/engine/src/example_transport.cpp")
        set(DARTWIC_EXAMPLE_PLUGIN_SOURCE "${local_plugin}")
    else()
        include(FetchContent)
        FetchContent_Declare(example_plugin
            GIT_REPOSITORY https://github.com/kemptonburton/dartwic-example-plugin.git
            GIT_TAG 30eba35438b2e327d405335459b556add3baf08a)
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
if(NOT TARGET DARTWIC::EngineProtocol)
add_subdirectory("${plugin}/vendor/engine-protocol" "${CMAKE_CURRENT_BINARY_DIR}/vendor/engine-protocol")
endif()
find_package(nlohmann_json CONFIG REQUIRED)
find_package(cppzmq CONFIG REQUIRED)

add_executable(rocket-flight-peer
    flight-computer/main.cpp
    "${plugin}/engine/src/example_transport.cpp")
target_include_directories(rocket-flight-peer PRIVATE "${plugin}/engine/include")
target_link_libraries(rocket-flight-peer PRIVATE
    DARTWIC::PeerClient cppzmq nlohmann_json::nlohmann_json)
if(WIN32)
    add_custom_command(TARGET rocket-flight-peer POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_RUNTIME_DLLS:rocket-flight-peer> $<TARGET_FILE_DIR:rocket-flight-peer>
        COMMAND_EXPAND_LISTS)
endif()

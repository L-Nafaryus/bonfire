cmake_minimum_required(VERSION 3.16)

project(hello-nix LANGUAGES CXX)

add_executable(hello-nix source/example.cpp)

install(
    TARGETS hello-nix
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT runtime
)

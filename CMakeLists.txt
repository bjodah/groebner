cmake_minimum_required(VERSION 3.22.1)
project(groebner CXX)

add_library(groebner "")
add_library(groebner::groebner ALIAS groebner)
target_sources(groebner PRIVATE
    
)
target_link_libraries(groebner
    
)
include(CTest)
add_executable(PolynomialTest PolynomialTest.cpp)
target_link_libraries(PolynomialTest groebner gtest)
add_test(NAME PolynomialTest COMMAND $<TARGET_FILE:PolynomialTest>)

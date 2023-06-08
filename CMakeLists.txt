cmake_minimum_required(VERSION 3.22.1)
project(groebner CXX)

find_package(Boost)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_MODULE_PATH})
find_package(FLINT REQUIRED)
find_package(MPIR REQUIRED)

add_library(groebner "")
add_library(groebner::groebner ALIAS groebner)
target_sources(groebner PRIVATE
    F5.cpp
    Monomial.cpp
    Ideal.cpp
    Polynomial.cpp
    debug.cpp
    integral.cpp
)
target_link_libraries(groebner
    Boost::boost
    flint2
    mpir
)
target_include_directories(groebner
    PRIVATE
    ${MPIR_INCLUDE_DIR}
)
include(CTest)
find_package(GTest REQUIRED)
add_executable(PolynomialTest
    F5Test.cpp
    #FGbTest.cpp
    IdealTest.cpp
    integralTest.cpp
    MMTest.cpp
    moGVWTest.cpp
    MonomialTest.cpp
    PolynomialTest.cpp
    TermTest.cpp
)
target_link_libraries(PolynomialTest
    groebner
    GTest::gtest
    GTest::gtest_main
)
target_include_directories(PolynomialTest
    PRIVATE    
    ${MPIR_INCLUDE_DIR}
    ${FLINT_INCLUDE_DIRS}
)
message("Flint include dir: ${FLINT_INCLUDE_DIRS}")
add_test(NAME PolynomialTest COMMAND $<TARGET_FILE:PolynomialTest>)

cmake_minimum_required(VERSION 3.22.1)
project(groebner CXX)

find_package(Boost)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_MODULE_PATH})
find_package(FLINT REQUIRED)
find_package(MPIR REQUIRED)
# message("Flint include dir: ${FLINT_INCLUDE_DIRS}")


add_library(groebner "")
add_library(groebner::groebner ALIAS groebner)
target_sources(groebner PRIVATE
    Monomial.cpp
    Ideal.cpp
    Polynomial.cpp
    debug.cpp
    integral.cpp
)
target_link_libraries(groebner
    Boost::boost
    flint
    mpir
)
target_include_directories(groebner
    PUBLIC
    ${MPIR_INCLUDE_DIR}
    ${FLINT_INCLUDE_DIRS}
)

add_executable(F5
    F5.cpp
)
target_link_libraries(F5
    groebner
)

add_executable(interreduce
    interreduce.cpp
)
target_link_libraries(interreduce
    groebner
)

include(CTest)
find_package(GTest REQUIRED)
add_executable(test-runner
    test-runner.cpp
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
target_link_libraries(test-runner
    groebner
    GTest::gtest
    GTest::gtest_main
)
add_test(NAME test-runner COMMAND $<TARGET_FILE:test-runner>)

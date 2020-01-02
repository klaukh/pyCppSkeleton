#include <catch.hpp>
#include "hello_world_cpp.hpp"

TEST_CASE("Hello World")
{
    greeting_cpp();
    SUCCEED();
}


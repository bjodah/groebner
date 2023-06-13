#include <gtest/gtest.h>
#include <sstream>

#include "Ideal.h"
#include "Polynomial.h"

using namespace std;
using namespace groebner;

TEST(IdealTest, Input)
{
    get_var_name = var_name;

    using P = Polynomial<>;
    using T = typename P::TermType;
    using M = typename P::MonomialType;

    stringstream ss("a,b,c\na,b*c,a+b+c");

    auto ideal = read_input<P>(ss);

    T a = T(1, M::x(0));
    T b = T(1, M::x(1));
    T c = T(1, M::x(2));

    EXPECT_EQ(vector<P>({ P{a}, P{b * c}, a + b + c }), ideal);
}

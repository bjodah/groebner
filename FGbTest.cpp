#include <gtest/gtest.h>
#include <mpirxx.h>

#include "FGb.h"

#include "CachedMonomial.h"
#include "ImmutablePolynomial.h"

using namespace std;
using namespace groebner;

TEST(FGbTest, FGb)
{
    use_abc_var_names in_this_scope;
    FGbRunner<char, 4> runner;
    using P = FGbRunner<char, 4>::P;
    using T = typename P::TermType;
    using M = typename P::MonomialType;

    T a = T(1, M::x(0));
    T b = T(1, M::x(1));
    T c = T(1, M::x(2));

    P f1 = a * b * c;
    P f2 = a * b - c;
    P f3 = b * c - b;

    vector<P> input = { f1, f2, f3 };

    auto output = runner.fgb(input);

    EXPECT_EQ(vector<P>({ c, b }), output);
}

TEST(FGbTest, hcyclic3)
{
    use_abc_var_names in_this_scope;
    FGbRunner<char, 4> runner;
    using P = FGbRunner<char, 4>::P;
    using T = typename P::TermType;
    using M = typename P::MonomialType;

    T a = T(1, M::x(0));
    T b = T(1, M::x(1));
    T c = T(1, M::x(2));
    T t = T(1, M::x(3));

    vector<P> input = {
        a + b + c,
        a * b + a * c + b * c,
        a * b * c - pow(t, 3)
    };

    auto output = runner.fgb(input);

    EXPECT_EQ(vector<P>({ a + b + c, pow(b, 2) + b * c + pow(c, 2), pow(c, 3) - pow(t, 3) }), output);
}

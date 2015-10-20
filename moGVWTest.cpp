#include <gtest/gtest.h>
#include <mpirxx.h>

#include "moGVW.h"

using namespace std;

TEST(moGVWTest, LCMCriterion) {
  use_abc_var_names in_this_scope;
  typedef Monomial<> M;
  typedef Term<> T;
  typedef Polynomial<> P;
  typedef moGVWRunner<>::LMSet LMSet;
  moGVWRunner<> runner;

  T a = T(1, M::x(0));
  T b = T(1, M::x(1));
  T c = T(1, M::x(2));

  P f1 = a*b*c - 1;
  P f2 = a*b - c;
  P f3 = b*c - b;

  MonRl<> e1 = MonRl<>::e(0);
  MonRl<> e2 = MonRl<>::e(1);
  MonRl<> e3 = MonRl<>::e(2);

  auto r1 = MM<>(e1, f1);
  auto r2 = MM<>(e2, f2);
  auto r3 = MM<>(e3, f3);
  auto r4 = MM<>(e1, c - 1);

  LMSet GG;
  GG[(a*b).m()] = r2;
  GG[(b*c).m()] = r3;
  GG[(b*c*c).m()] = r3;
  GG[(b*b*c).m()] = r3;
  GG[(a*b*c).m()] = r3;
  GG[(c).m()] = r4;
  GG[(c*c).m()] = r4;
  GG[(a*c).m()] = r4;
  GG[(a*c*c).m()] = r4;

  EXPECT_TRUE(runner.rejectedByLCMCriterion((a*b*c).m(), r4, GG));
}

TEST(moGVWTest, lift) {
  use_abc_var_names in_this_scope;
  typedef Monomial<> M;
  typedef Term<> T;
  typedef Polynomial<> P;
  typedef moGVWRunner<>::LMSet LMSet;
  typedef moGVWRunner<>::MMSet MMSet;
  moGVWRunner<> runner;

  T a = T(1, M::x(0));
  T b = T(1, M::x(1));
  T c = T(1, M::x(2));

  P f1 = a*b*c - 1;
  P f2 = a*b - c;
  P f3 = b*c - b;

  MonRl<> e1 = MonRl<>::e(0);
  MonRl<> e2 = MonRl<>::e(1);
  MonRl<> e3 = MonRl<>::e(2);

  auto r1 = MM<>(e1, f1);
  auto r2 = MM<>(e2, f2);
  auto r3 = MM<>(e3, f3);
  auto r4 = MM<>(e1, c - 1);

  LMSet GG;
  GG[(a*b*c).m()] = r1;
  GG[(a*b).m()] = r2;
  GG[(b*c).m()] = r3;

  LMSet todo;
  todo[(b*c).m()] = r3;

  MMSet HH = runner.lift(todo, GG);

  LMSet GG2;
  GG2[(a*b).m()] = r2;
  GG2[(b*c).m()] = r3;
  GG2[(b*c*c).m()] = r3;
  GG2[(b*b*c).m()] = r3;
  GG2[(a*b*c).m()] = r3;
  GG2[(c).m()] = r4;
  GG2[(c*c).m()] = r4;
  GG2[(a*c).m()] = r4;
  GG2[(a*c*c).m()] = r4;
}

TEST(moGVWTest, moGVW) {
  use_abc_var_names in_this_scope;
  typedef Polynomial<Term<int, Monomial<char, 3> > > P;
  typedef typename P::TermType T;
  typedef typename P::MonomialType M;
  moGVWRunner<P> runner;

  T a = T(1, M::x(0));
  T b = T(1, M::x(1));
  T c = T(1, M::x(2));

  P f1 = a*b*c - 1;
  P f2 = a*b - c;
  P f3 = b*c - b;

  set<P> input = { f1, f2, f3 };

  set<P> output = runner.moGVW(input);

  EXPECT_EQ(set<P>({c-1, a*b-1}), output);
}

TEST(moGVWTest, cyclic3) {
  use_abc_var_names in_this_scope;
  typedef Polynomial<Term<int, Monomial<char, 3> > > P;
  typedef typename P::TermType T;
  typedef typename P::MonomialType M;
  moGVWRunner<P> runner;

  T a = T(1, M::x(0));
  T b = T(1, M::x(1));
  T c = T(1, M::x(2));

  set<P> input = {
    a + b + c,
    a*b + a*c + b*c,
    a*b*c - 1
  };

  set<P> output = runner.moGVW(input);

  EXPECT_EQ(set<P>({pow(c,3)-1, pow(b,2)+b*c+pow(c,2), a+b+c}), output);
}

TEST(moGVWTest, cyclic4) {
  use_abc_var_names in_this_scope;
  typedef Polynomial<Term<int, Monomial<char, 4> > > P;
  typedef typename P::TermType T;
  typedef typename P::MonomialType M;
  moGVWRunner<P> runner;

  T a = T(1, M::x(0));
  T b = T(1, M::x(1));
  T c = T(1, M::x(2));
  T d = T(1, M::x(3));

  set<P> input = {
    a + b + c + d,
    a*b + b*c + a*d + c*d,
    a*b*c + a*b*d + a*c*d + b*c*d,
    a*b*c*d - 1
  };

  set<P> output = runner.moGVW(input);

  EXPECT_EQ(set<P>({
    pow(c,2)*pow(d,6)-pow(c,2)*pow(d,2)-pow(d,4)+1,
    pow(c,3)*pow(d,2)+pow(c,2)*pow(d,3)-c-d,
    b*pow(d,4)-b+pow(d,5)-d,
    b*c-b*d+pow(c,2)*pow(d,4)+c*d-2*pow(d,2),
    pow(b,2)+2*b*d+pow(d,2),
    a+b+c+d
  }), output);
}

TEST(moGVWTest, cyclic5mpz_class) {
  use_abc_var_names in_this_scope;
  typedef Polynomial<Term<mpz_class, Monomial<char, 5> > > P;
  typedef typename P::TermType T;
  typedef typename P::MonomialType M;
  moGVWRunner<P> runner;

  T a = T(1, M::x(0));
  T b = T(1, M::x(1));
  T c = T(1, M::x(2));
  T d = T(1, M::x(3));
  T e = T(1, M::x(4));

  set<P> input = {
    a*b*c*d*e -1L,
    a*b*c*d + a*b*c*e + a*b*d*e + a*c*d*e + b*c*d*e,
    a*b*c + a*b*e + a*d*e + b*c*d + c*d*e,
    a*b + a*e + b*c + c*d + d*e,
    a + b + c + d + e
  };

  set<P> output = runner.moGVW(input);

  EXPECT_EQ(set<P>({
    pow(e,15)+mpz_class(122)*pow(e,10)-mpz_class(122)*pow(e,5)-mpz_class(1),
    mpz_class(55)*pow(d,2)*pow(e,5)-mpz_class(55)*pow(d,2)-mpz_class(2)*d*pow(e,11)-mpz_class(231)*d*pow(e,6)+mpz_class(233)*d*e-mpz_class(8)*pow(e,12)-mpz_class(979)*pow(e,7)+mpz_class(987)*pow(e,2),
    mpz_class(55)*pow(d,7)+mpz_class(165)*pow(d,6)*e+mpz_class(55)*pow(d,5)*pow(e,2)-mpz_class(55)*pow(d,2)-mpz_class(398)*d*pow(e,11)-mpz_class(48554)*d*pow(e,6)+mpz_class(48787)*d*e-mpz_class(1042)*pow(e,12)-mpz_class(127116)*pow(e,7)+mpz_class(128103)*pow(e,2),
    mpz_class(55)*c*pow(e,5)-mpz_class(55)*c+pow(e,11)+mpz_class(143)*pow(e,6)-mpz_class(144)*e,
    mpz_class(275)*c*d-mpz_class(275)*c*e+mpz_class(440)*pow(d,6)*e+mpz_class(1210)*pow(d,5)*pow(e,2)-mpz_class(275)*pow(d,3)*pow(e,4)+mpz_class(275)*pow(d,2)-mpz_class(442)*d*pow(e,11)-mpz_class(53911)*d*pow(e,6)+mpz_class(53913)*d*e-mpz_class(1121)*pow(e,12)-mpz_class(136763)*pow(e,7)+mpz_class(136674)*pow(e,2),
    mpz_class(275)*pow(c,3)+mpz_class(550)*pow(c,2)*e-mpz_class(550)*c*pow(e,2)+mpz_class(275)*pow(d,6)*pow(e,2)+mpz_class(550)*pow(d,5)*pow(e,3)-mpz_class(550)*pow(d,4)*pow(e,4)+mpz_class(550)*pow(d,2)*e-mpz_class(232)*d*pow(e,12)-mpz_class(28336)*d*pow(e,7)+mpz_class(28018)*d*pow(e,2)-mpz_class(568)*pow(e,13)-mpz_class(69289)*pow(e,8)+mpz_class(69307)*pow(e,3),
    mpz_class(55)*b*pow(e,5)-mpz_class(55)*b+pow(e,11)+mpz_class(143)*pow(e,6)-mpz_class(144)*e,
    mpz_class(275)*b*d-mpz_class(275)*b*e-mpz_class(110)*pow(d,6)*e-mpz_class(440)*pow(d,5)*pow(e,2)-mpz_class(275)*pow(d,4)*pow(e,3)+mpz_class(275)*pow(d,3)*pow(e,4)+mpz_class(124)*d*pow(e,11)+mpz_class(15092)*d*pow(e,6)-mpz_class(15106)*d*e+mpz_class(346)*pow(e,12)+mpz_class(42218)*pow(e,7)-mpz_class(42124)*pow(e,2),
    mpz_class(275)*b*c-mpz_class(275)*b*e+mpz_class(275)*pow(c,2)+mpz_class(550)*c*e-mpz_class(330)*pow(d,6)*e-mpz_class(1045)*pow(d,5)*pow(e,2)-mpz_class(275)*pow(d,4)*pow(e,3)+mpz_class(275)*pow(d,3)*pow(e,4)-mpz_class(550)*pow(d,2)+mpz_class(334)*d*pow(e,11)+mpz_class(40722)*d*pow(e,6)-mpz_class(40726)*d*e+mpz_class(867)*pow(e,12)+mpz_class(105776)*pow(e,7)-mpz_class(105873)*pow(e,2),
    mpz_class(275)*pow(b,2)+mpz_class(825)*b*e+mpz_class(550)*pow(d,6)*e+mpz_class(1650)*pow(d,5)*pow(e,2)+mpz_class(275)*pow(d,4)*pow(e,3)-mpz_class(550)*pow(d,3)*pow(e,4)+mpz_class(275)*pow(d,2)-mpz_class(566)*d*pow(e,11)-mpz_class(69003)*d*pow(e,6)+mpz_class(69019)*d*e-mpz_class(1467)*pow(e,12)-mpz_class(178981)*pow(e,7)+mpz_class(179073)*pow(e,2),
    a+b+c+d+e
  }), output);
}

#pragma once
#ifndef MATRIX_H
#define MATRIX_H

#include "Polynomial.h"
#include "debug.h"

namespace groebner {

template <uint ROWS, uint COLS, class P = Polynomial<Term<int, Monomial<char>>>>
struct CoefficientMatrix {
    using M = typename P::MonomialType;
    using T = typename P::TermType;
    using C = typename P::CoefficientType;
};

template <uint ROWS, uint COLS, class P = Polynomial<Term<int, Monomial<char>>>>
struct UpperTriangularSparse : public CoefficientMatrix<ROWS, COLS, P> {
};

template <uint ROWS, uint COLS, class P = Polynomial<Term<int, Monomial<char>>>>
struct Dense : public CoefficientMatrix<ROWS, COLS, P> {
};

} // namespace groebner

#endif // MATRIX_H

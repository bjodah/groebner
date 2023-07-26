#ifndef SIGNATURE_H
#define SIGNATURE_H

#include <array>
#include <limits>
#include <ostream>
#include <stdexcept>

#include "Polynomial.h"
#include "style.h"

/* lead monomials of elements of R^l, i.e. x^{...}*e_i */
template <class P = Polynomial<Term<int, Monomial<char>>>>
class Signature {
public:
    typedef typename P::TermType::MonomialType MonomialType;
    typedef typename P::TermType::CoefficientType CoefficientType;
    typedef typename P::TermType TermType;
    typedef Signature<P> This;

    Signature()
        : m()
        , index(std::numeric_limits<uint>::max())
    {
    }
    Signature(const MonomialType& monomial, uint i)
        : m(monomial)
        , index(i)
    {
    }

    static This e(int i)
    {
        This result;
        result.index = i;
        return result;
    }
    bool operator==(const This& other) const
    {
        return index == other.index && m == other.m;
    }

    bool operator<(const This& other) const
    {
        uint i = index;
        uint j = other.index;
        if (i > j)
            return true;
        if (i == j && m < other.m)
            return true;
        return false;
    }
    bool operator>(const This& other) const { return other < *this; }

    bool divides(const This& other) const
    {
        if (index != other.index)
            return false;
        return m.divides(other.m);
    }

    MonomialType operator/(const This& other) const
    {
        if (!other.divides(*this))
            throw std::domain_error("does not divide");
        return m / other.m;
    }

    This& operator*=(const TermType& b)
    {
        m *= b.m();
        return *this;
    }
    This operator*(const TermType& b) const
    {
        This r(*this);
        r *= b;
        return r;
    }

    This& operator*=(const MonomialType& b)
    {
        m *= b;
        return *this;
    }
    This operator*(const MonomialType& b) const
    {
        This r(*this);
        r *= b;
        return r;
    }

    template <class P1>
    friend std::ostream& operator<<(std::ostream&, const Signature<P1>&);

    MonomialType m;
    uint index;
};

template <class P>
Signature<P> operator*(const typename P::MonomialType& a, const Signature<P>& b)
{
    return b * a;
}

template <class P>
Signature<P> operator*(const typename P::TermType& a, const Signature<P>& b)
{
    return b * a;
}

template <class P>
std::ostream& operator<<(std::ostream& out, const Signature<P>& u)
{
    if (!u.m.isConstant())
        out << u.m << "*";
    return out << "e_" << u.index;
}

#endif // SIGNATURE_H
// vim:ruler:cindent:shiftwidth=2:expandtab:

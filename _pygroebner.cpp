#include <nanobind/nanobind.h>
#include <nanobind/stl/string.h>

#include "F5.h"
#include "Polynomial.h"
namespace gr = groebner;

template<typename P>
std::vector<std::string> calc_gbasis(const std::vector<std::string> &args, const std::vector<std::string> &polys) {
    return {};
}

std::vector<std::string> calc_groebner_basis(const std::vector<std::string> &args, const std::vector<std::string> &polys, const std::string method, const std::string ordering)
{
    using F5_lexicogra_2 = ;
    using F5_degrevlex_2 = gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 2, gr::degrevlex>>>;
    if (method == "F5") {
        if (ordering == "lex") {
            switch (args.size()) {
            case 2: return calc_gbasis<gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 2, gr::lex>>>>(args, polys);
            case 3: return calc_gbasis<gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 3, gr::lex>>>>(args, polys);
            case 4: return calc_gbasis<gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 4, gr::lex>>>>(args, polys);
            case 5: return calc_gbasis<gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 5, gr::lex>>>>(args, polys);
            case 6: return calc_gbasis<gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 6, gr::lex>>>>(args, polys);
            case 7: return calc_gbasis<gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 7, gr::lex>>>>(args, polys);
            case 8: return calc_gbasis<gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 8, gr::lex>>>>(args, polys);
            default:
                throw std::runtime_error("unsupported number of variables in groebner calc");
            }
        } else if (ordering == "degrevlex") {

        } else {
            throw std::runtime_error("unknown groebner calc ordering");
        }
    } else if (method == "moGVW") {

    } else {
        throw std::runtime_error("unknown groebner calc method");
    }
}

NB_MODULE(_pygroebner, m) {
    m.def("calc_groebner_basis", calc_groebner_basis);
}

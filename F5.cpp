#include <fstream>
#include <iostream>

#include <flint/fmpzxx.h>

#include "F5.h"
#include "Ideal.h"
#include "integral.h"

namespace gr = groebner;

int main(int argc, char* argv[])
{
    gr::get_var_name = gr::var_name;

    typedef gr::Polynomial<gr::Term<flint::fmpzxx, gr::Monomial<char, 64, gr::degrevlex>>> P;

    std::vector<P> input;
    if (argc > 1) {
        D("reading input from file " << argv[1]);
        std::ifstream in_file(argv[1]);
        input = gr::read_input<P>(in_file);
    } else {
        D("reading input from stdin");
        input = gr::read_input<P>(std::cin);
    }
    DD("input = ", input);
    gr::F5Runner<P> runner;
    auto output = runner.f5(input);
    for (auto & it : output) {
        std::cout << it << std::endl;
    }
    return 0;
}

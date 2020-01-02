#include <pybind11/pybind11.h>
#include "hello_world_cpp.hpp"

void greeting_cpp()
{
    std::cout << "Hello World, from C++!" << std::endl;
}

namespace py = pybind11;

PYBIND11_MODULE(hello_world_cpp, m)
{
    m.doc() = R"pbdoc(
        A Pybind11 example
        ------------------
        .. currentmodule:: hello_world_cpp
        .. autosummary::
           :toctree: _generate

           greeting_cpp
    )pbdoc";

    m.def("greeting_cpp", &greeting_cpp, R"pbdoc(
        Saying hello from C++    
    )pbdoc");

#ifdef VERSION_INFO
    m.attr("__version__") = VERSION_INFO;
#else
    m.attr("__version__") = "dev";
#endif
}


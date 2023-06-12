#pragma once
#ifndef STYLE_H
#define STYLE_H

#include <iomanip>
#include <sstream>
#include <string>

using uint = unsigned int;
using ulong = unsigned long;

template <class T>
std::string to_string(const T& t)
{
    std::stringstream s;
    s << t;
    return s.str();
}

inline std::string to_string(uint i, uint width)
{
    std::stringstream s;
    s << std::setw((int)width) << std::setfill('0') << i;
    return s.str();
}

template <class T>
T from_string(const std::string& s)
{
    T t;
    std::stringstream ss(s);
    ss >> t;
    return t;
}

#endif // STYLE_H

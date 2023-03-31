#pragma once

#include <map>
#include <set>
#include <string>
#include <fstream>
#include "scanner.h"
#include "parser.hh"


class Driver {
 public:
    Driver();

    int parse(const std::string& f);
    void PrepareJson(std::ofstream&);

    // options
    bool trace_parsing{false};
    bool trace_scanning{false};
    bool location_debug{false};

private:
    void OutputInclude(std::ofstream&);
    void OutputImport(std::ofstream&);
    void OutputReference(std::ofstream&);
    void OutputLet(std::ofstream&);

    void scan_begin();
    void scan_end();

private:
    friend class Scanner;

public:
    size_t offset_{0};
    std::set<std::string> include_;
    std::map<std::string, std::string> let_;
    std::map<std::string, std::string> import_;
    std::map<std::string, size_t> reference_;

private:
    std::string file;
    yy::location location;
    Scanner scanner;
    yy::parser parser;
    std::ifstream stream;
};

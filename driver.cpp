#include "driver.hh"
#include "parser.hh"



Driver::Driver() :
    trace_parsing(false),
    trace_scanning(false),
    location_debug(false),
    scanner(*this), parser(scanner, *this) {
}


int Driver::parse(const std::string& f) {
    file = f;
    location.initialize(&file);

    scan_begin();
    parser.set_debug_level(trace_parsing);
    parser();
    scan_end();

    return 0;
}

void Driver::scan_begin() {
    scanner.set_debug(trace_scanning);
    if (!file.empty () || file == "-") {
        stream.open(file);
        if (location_debug) {
            std::cerr << "File name is " << file << std::endl;
        }
        scanner.yyrestart(&stream);
  }
}

void Driver::scan_end() {
    stream.close();
}

void Driver::PrepareJson(std::ofstream& file) {
    file << "{" << std::endl;
    OutputInclude(file);
    file << "," << std::endl;
    OutputImport(file);
    file << "," << std::endl;
    OutputLet(file);
    file << "," << std::endl;
    OutputReference(file);
    file << "}" << std::endl;
}
void Driver::OutputInclude(std::ofstream& file) {
    file << "\"include\" : ";
    file << "[";
    size_t s = 0;
    for (auto& el : include_) {
        if (include_.size() - 1 != s) {
            file << "\"" << el << "\"" << ", ";
        } else {
            file << "\"" << el << "\"";
        }
        ++s;
    }
    file << "]";
}
void Driver::OutputImport(std::ofstream& file) {
    file << "\"import\" : ";
    file << "[";
    size_t s = 0;
    for (auto& el : import_) {
        if (include_.size() - 1 != s) {
            file << "{";
            file << "\"names\" : ";
            file << "[";
            file << "\"" << el.first << "\"";
            file << "],";
            file << "\"source\" : " << "\"" << el.second << "\"},";
        } else {
            file << "{";
            file << " \"names\" : ";
            file << "[";
            file << "\"" << el.first << "\"";
            file << "],";
            file << "\"source\" : " << "\"" << el.second << "\"}";
        }
        ++s;
    }
    file << "]";
}
void Driver::OutputLet(std::ofstream& file) {
    file << "\"let\" : ";
    file << "[";
    size_t s = 0;
    for (auto& el : let_) {
        if (let_.size() - 1 != s) {
            file << "{";
            file << "\"name\" : ";
            file << "\"" << el.first << "\"";
            file << ",";
            file << "\"value\" : " << "\"" << el.second << "\"},";
        } else {
            file << "{";
            file << "\"name\" : ";
            file << "\"" << el.first << "\"";
            file << ",";
            file << "\"value\" : " << "\"" << el.second << "\"}";
        }
        ++s;
    }
    file << "]";
}
void Driver::OutputReference(std::ofstream& file) {
    file << "\"reference\" : ";
    file << "[";
    size_t s = 0;
    for (auto& el : reference_) {
        if (reference_.size() - 1 != s) {
            file << "{";
            file << "\"name\" : ";
            file << "\"" << el.first << "\"";
            file << ",";
            file << "\"pos\" : " << "\"" << el.second << "\"},";
        } else {
            file << "{";
            file << "\"name\" : ";
            file << "\"" << el.first << "\"";
            file << ",";
            file << "\"pos\" : " << "\"" << el.second << "\"}";
        }
        ++s;
    }
    file << "]";
}


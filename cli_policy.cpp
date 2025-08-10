#include <iostream>
#include <stdio.h>
#include <string>
#include <ctype.h>
#include <assert.h>

#include "util/strencodings.h"
#include "script/miniscript.h"
#include "compiler.h"

using miniscript::operator"" _mst;

static bool run(std::string&& line, int64_t count) {
    if (line.size() && line.back() == '\n') line.pop_back();
    if (line.size() == 0) return false;

    miniscript::NodeRef<std::string> ret;
    double avgcost = 0;
    if (Compile(Expand(line), ret, avgcost)) {
        // policy to miniscript and asm
        auto str = ret->ToString(COMPILER_CTX);
        assert(str);
        auto script = ret->ToScript(COMPILER_CTX);
        printf("<<Spending cost>>\nscript_size=%d\naverage_input_size=%f\naverage_total_cost=%f\n\n",
                (int)ret->ScriptSize(),
                avgcost,
                ret->ScriptSize() + avgcost);
        printf("<<miniscript output>>\n%s\n\n",
            Abbreviate(std::move(*str)).c_str());
        printf("<<Resulting script structure>>\n%s\n",
            Disassemble(script).c_str());
        printf("<<Resulting script (hex)>>\n%s\n\n",
            HexStr(script.begin(), script.end()).c_str());
    } else if ((ret = miniscript::FromString(Expand(line), COMPILER_CTX))) {
        printf("Failed to parse as policy: '%s'\n", line.c_str());
    }
    return true;
}

int main(void) {
    int64_t count = 0;
    do {
        std::string line;
        std::getline(std::cin, line);
        if (!run(std::move(line), count++)) break;
    } while(true);
}

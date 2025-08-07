HEADERS := \
	bitcoin/util/vector.h \
	bitcoin/util/strencodings.h \
	bitcoin/span.h \
	bitcoin/util/spanparsing.h \
	bitcoin/script/script.h \
	bitcoin/script/miniscript.h \
	compiler.h \
	bitcoin/crypto/common.h \
	bitcoin/serialize.h \
	bitcoin/prevector.h \
	bitcoin/compat/endian.h \
	bitcoin/compat/byteswap.h \
	bitcoin/attributes.h \
	bitcoin/tinyformat.h \
	bitcoin/primitives/transaction.h
SOURCES := \
	bitcoin/util/strencodings.cpp \
	bitcoin/util/spanparsing.cpp \
	bitcoin/script/script.cpp \
	bitcoin/script/miniscript.cpp \
	compiler.cpp

FLAGS := -O3 -g0 -Wall -std=c++17 -Ibitcoin
CFLAGS := $(FLAGS) -march=native
EMFLAGS := $(FLAGS) -fno-rtti

miniscript: $(HEADERS) $(SOURCES) main.cpp
	g++ $(CFLAGS) $(SOURCES) main.cpp -o miniscript

miniscript.js: $(HEADERS) $(SOURCES) js_bindings.cpp
	em++ $(EMFLAGS) $(SOURCES) js_bindings.cpp -s WASM=1 -s FILESYSTEM=0 -s ENVIRONMENT=web -s DISABLE_EXCEPTION_CATCHING=0 -s EXPORTED_FUNCTIONS='["_miniscript_compile","_miniscript_analyze","_malloc","_free"]' -s EXPORTED_RUNTIME_METHODS='["cwrap","UTF8ToString"]' -o miniscript.js

wrapper.dot: wrapper.txt
	(echo "digraph wrapper {"; cat wrapper.txt | sed -e 's/^ \+//g' | sed -e 's/ \+/ /g' | cut -d ' ' -f 2 | rev | sed -e 's/l/u/g' | sed -e 's/s/a/g' | sort | uniq | sed -e 's/\([a-z]\)/\1,\1/g' | sed -e 's/^[a-z]//g' | sed -e 's/,[a-z]$$//g' | sed -e 's/,\(.\)\(.\)/  \1 -> \2;\n/g' | sort | uniq | sed -e 's/u/"l\/u"/g' | sed -e 's/a/\"a\/s\"/g'; echo "}") >wrapper.dot

wrapper.pdf: wrapper.dot
	dot -Tpdf <wrapper.dot >wrapper.pdf

clean:
	@rm -f miniscript miniscript.js miniscript.wasm

BUILDDIR := $(shell pwd)
CC := $(shell echo gcc)
CXX := $(shell echo g++)
GTEST_VERSION := 1.17.0
GTEST := googletest-$(GTEST_VERSION)
FLINT_VERSION := 3.3.1
# note that flint v3+ no longer supports MPIR
FLINT := flint-$(FLINT_VERSION)
FLINT_URL := "https://github.com/flintlib/flint/releases/download/v$(FLINT_VERSION)/$(FLINT).tar.gz"
FLINT_SHA256_TGZ := 64d70e513076cfa971e0410b58c1da5d35112913e9a56b44e2c681b459d3eafb
#MPIR := mpir-3.0.0
MPFR := mpfr-4.2.2
PNG := libpng-1.6.49

FGB_LIBDIR := $(BUILDDIR)/call_FGb/nv/maple/C/$(shell uname | grep Linux >/dev/null && echo x64 || echo macosx)
CXXFLAGS := -std=c++17 -m64 -O3 -Wall
LDFLAGS := -L$(BUILDDIR)/lib -lflint -lmpfr -lgmp $(shell $(CC) -v 2>&1 | grep gcc >/dev/null && echo -fopenmp) -pthread -lpng -lz
FGB_LDFLAGS := -L$(FGB_LIBDIR) $(shell uname | grep Linux >/dev/null && echo -Wl,-allow-multiple-definition) -lfgb -lfgbexp -lgb -lgbexp -lminpoly -lminpolyvgf -lgmp -lm
CPPFLAGS := -I$(BUILDDIR)/include -I$(BUILDDIR)/include/flint -DINFO
FGB_CPPFLAGS := -I$(BUILDDIR)/call_FGb/nv/protocol -I$(BUILDDIR)/call_FGb/nv/int -I$(BUILDDIR)/call_FGb/nv/maple/C -Wno-write-strings -Wno-unused-but-set-variable -Wno-unused-function

all: moGVW F5 FGb interreduce intercept.so test

moGVW: moGVW.o Monomial.o Ideal.o Polynomial.o debug.o integral.o
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

moGVW.o: moGVW.cpp *.h include/flint/fmpz.h include/png.h lib/libpng.a  # include/mpir.h include/mpirxx.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c -o $@ $<

clean:
	rm -rf moGVW *.o *.dSYM test-runner FGb F5 gmon.out

distclean: clean
	rm -rf include lib share bin $(MPIR) $(MPFR) $(FLINT) $(GTEST) $(PNG) call_FGb

#.downloads/$(MPIR).tar.bz2:
#	mkdir -p .downloads && cd .downloads && wget --continue	https://web.archive.org/web/20220204054313/http://mpir.org/$(MPIR).tar.bz2

#$(MPIR): .downloads/$(MPIR).tar.bz2
#	tar jxf $<

#lib/libmpir.a include/mpir.h include/mpirxx.h lib/libgmp.a include/gmp.h: $(MPIR)
#	cd $< && CC="$(CC)" ./configure --enable-gmpcompat --enable-cxx --disable-shared --enable-static --prefix=$(BUILDDIR) && make && make install

.downloads/$(MPFR).tar.bz2:
	mkdir -p .downloads && cd .downloads && wget --continue http://www.mpfr.org/mpfr-current/$(MPFR).tar.bz2

$(MPFR): .downloads/$(MPFR).tar.bz2
	tar jxf $<

lib/libmpfr.a include/mpfr.h: $(MPFR) # lib/libgmp.a
	cd $< && CC="$(CC)" ./configure --disable-shared --with-gmp=$(BUILDDIR) --prefix=$(BUILDDIR) && make && make check && make install

.downloads/$(FLINT).tar.gz:
	mkdir -p .downloads && cd .downloads && wget --no-check-certificate "$(FLINT_URL)" && echo "$(FLINT_SHA256_TGZ)  $(FLINT).tar.gz" | sha256sum -c -

$(FLINT): .downloads/$(FLINT).tar.gz
	tar zxf $<

lib/libflint.a include/flint/flint.h include/flint/fmpz.h include/flint/fmpzxx.h: $(FLINT) lib/libmpfr.a
	cd $< && \
	env CC="$(CC)" ./configure --disable-shared --enable-cxx --prefix=$(BUILDDIR) --with-mpfr=$(BUILDDIR) && \
	make && \
	make install
#--with-mpir=$(BUILDDIR) --with-gmp=$(BUILDDIR)

.downloads/call_FGb6.maclinux.x64.tar.gz:
	mkdir -p .downloads && cd .downloads && wget --continue http://www-polsys.lip6.fr/~jcf/FGb/C/@downloads/call_FGb6.maclinux.x64.tar.gz

call_FGb: .downloads/call_FGb6.maclinux.x64.tar.gz
	test -e $@ || tar zxf $<

.downloads/v$(GTEST_VERSION).zip:
	mkdir -p .downloads && cd .downloads && wget --continue https://github.com/google/googletest/archive/refs/tags/v$(GTEST_VERSION).zip

$(GTEST): .downloads/v$(GTEST_VERSION).zip
	test -e $@ || unzip $<

.downloads/$(PNG).tar.gz:
	mkdir -p .downloads && cd .downloads && wget --continue http://prdownloads.sourceforge.net/libpng/$(PNG).tar.gz

$(PNG): .downloads/$(PNG).tar.gz
	test -e $@ || tar zxf $<

lib/libpng.a include/png.h: $(PNG)
	cd $(PNG) && CC=$(CC) ./configure --prefix=$(BUILDDIR) --disable-shared && make && make install

libs: lib/libflint.a lib/libpng.a  # lib/libmpir.a

test: test-runner
	./test-runner

%Test.o: %Test.cpp %.h include/flint/fmpzxx.h include/gtest/gtest.h lib/libpng.a  # include/mpirxx.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c -isystem $(GTEST)/include -o $@ $<

lib/libgtest.a lib/libgtest_main.a include/gtest/gtest.h: $(GTEST)
	mkdir -p $(GTEST)/build && cd $(GTEST)/build && cmake .. -DBUILD_GMOCK=OFF --install-prefix=/groebner/ && make && make install

TEST_OBJECTS := $(shell ls *Test.cpp | sed -e s/cpp$$/o/g)

test-runner: $(TEST_OBJECTS) lib/libgtest.a lib/libgtest_main.a Monomial.o Ideal.o Polynomial.o debug.o integral.o
	$(CXX) $^ -o test-runner $(LDFLAGS) $(FGB_LDFLAGS)

%.o: %.cpp %.h lib/libpng.a
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -c -o $@ $<

FGb.o: FGb.cpp FGb.h Monomial.h Polynomial.h call_FGb lib/libpng.a
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(FGB_CPPFLAGS) -c -o $@ $<

FGbTest.o: FGbTest.cpp FGb.h Monomial.h Polynomial.h call_FGb lib/libpng.a
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(FGB_CPPFLAGS) -c -o $@ $< -isystem $(GTEST)/include

FGb: FGb.o Monomial.o Ideal.o Polynomial.o debug.o integral.o
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) $(FGB_LDFLAGS)

F5: F5.o Monomial.o Ideal.o Polynomial.o debug.o integral.o
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

interreduce: interreduce.o Monomial.o Ideal.o Polynomial.o debug.o integral.o
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

%.mp4:
	ffmpeg -framerate 25 -pattern_type glob -i '$**.png' -vf scale='flags=neighbor:w=trunc((iw+1)/2)*2:h=trunc((ih+1)/2)*2' -c:v libx264 -pix_fmt yuv420p $@

%.so: %.c
	$(CC) $(CFLAGS) -fPIC -shared $(shell uname | grep Linux >/dev/null && echo -Wl,--no-as-needed) -ldl -o $@ $<

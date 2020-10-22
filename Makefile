# st - simple terminal
# See LICENSE file for copyright and license details.
.POSIX:


#########################################
# VARIABLES - overridable by make flags #
#########################################
CFLAGS = -Iinclude -Iinc -Isrc -Wall -Wextra \
       -Wno-implicit-fallthrough -Wno-unused-const-variable \
       -std=c11 -g3 -Os -D_FORTIFY_SOURCE=2 -fexceptions \
       -fasynchronous-unwind-tables -fpie -Wl,-pie \
       -fstack-protector-strong -grecord-gcc-switches \
       -Werror=format-security \
       -Werror=implicit-function-declaration -Wl,-z,defs -Wl,-z,now \
       -Wl,-z,relro $(EXTRA_CFLAGS)
LDFLAGS = $(EXTRA_LDFLAGS)
LDLIBS = -lm -lrt -lX11 -lutil -lXft $(shell pkg-config --libs fontconfig) $(shell pkg-config --libs freetype2) $(EXTRA_LDLIBS)
DESTDIR = /
VERSION = 0.8.4
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man
Q = @
SED = sed
CSCOPE = cscope
CTAGS = ctags
INSTALL = install

default: st

st: st.o x.o

clean:
	rm -f st *.o

install: $(DESTDIR)$(PREFIX)/bin/st

.PHONY: cscope
cscope: | cscope.files
	$(CSCOPE) -b -q -k

cscope.files: st.c.deps x.c.deps
	$(Q)cat $^ | sort | uniq > $@

.PHONY: tags
tags: | cscope.files
	$(CTAGS) -L cscope.files



##################
# IMPLICIT RULES #
##################

$(DESTDIR)$(PREFIX)/bin:
	@echo "INSTALL $@"
	$(Q)$(INSTALL) -m 0755 -d $@

$(DESTDIR)$(PREFIX)/lib:
	@echo "INSTALL $@"
	$(Q)$(INSTALL) -m 0755 -d $@

$(DESTDIR)$(PREFIX)/include:
	@echo "INSTALL $@"
	$(Q)$(INSTALL) -m 0755 -d $@

$(DESTDIR)$(PREFIX)/lib/%.so: %.so | $(DESTDIR)$(PREFIX)/lib
	@echo "INSTALL $@"
	$(Q)$(INSTALL) -m 0644 $< $@

$(DESTDIR)$(PREFIX)/lib/%.a: %.a | $(DESTDIR)$(PREFIX)/lib
	@echo "INSTALL $@"
	$(Q)$(INSTALL) -m 0644 $< $@

$(DESTDIR)$(PREFIX)/include/%.h: %.h | $(DESTDIR)$(PREFIX)/include
	@echo "INSTALL $@"
	$(Q)$(INSTALL) -m 0644 $< $@

$(DESTDIR)$(PREFIX)/bin/%: % | $(DESTDIR)$(PREFIX)/bin
	@echo "INSTALL $@"
	$(Q)$(INSTALL) -m 0755 $< $@

%: %.o
	@echo "LD $@"
	$(Q)$(CROSS_COMPILE)$(CC) $(LDFLAGS) -o $@ $^ $(LOADLIBES) $(LDLIBS)

%.o: %.c
	@echo "CC $@"
	$(Q)$(CROSS_COMPILE)$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $^

%.deps: %
	@echo "CC $@"
	$(Q)$(CC) -c $(CFLAGS) $(CPPFLAGS) -M $^ | $(SED) -e 's/[\\ ]/\n/g' | $(SED) -e '/^$$/d' -e '/\.o:[ \t]*$$/d' | sort | uniq > $@

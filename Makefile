.SUFFIXES: .cpp .o

ARCH = $(shell uname -m)
#ARCH = aarch64
PLAT = $(shell uname -s | tr '[:upper:]' '[:lower:]')-gnu
EXTRA = 
BIN = fes

#PLAT = w64-mingw32
#EXTRA = -lpsapi -liphlpapi
#BIN = fes.exe

CC = $(ARCH)-$(PLAT)-g++ -w
ifeq ($(ARCH), aarch64)
	CC = g++ -w
endif
INCDIR = -I./dep/include
LIBDIR = -L./dep/lib/$(ARCH)-$(PLAT)/

BINDIR  = ./bin/$(ARCH)-$(PLAT)
OBJDIR  = ./obj/$(ARCH)-$(PLAT)
SRCDIR  = ./src

CFLAGS = $(INCDIR) -std=c++17 -fopenmp -O2 -DTETLIBRARY -DTRILIBRARY
LFLAGS = $(LIBDIR) -std=c++17 -fopenmp -static \
	-lsmumps -ldmumps -lcmumps -lzmumps -lmumps_common -lmpiseq -lpord \
	-ltet -ltriangle \
	-larpack -lopenblas -lgfortran -lquadmath \
	$(EXTRA) \
	-Wl,--whole-archive -lpthread -Wl,--no-whole-archive
SRCS=$(wildcard  $(SRCDIR)/*.cpp)
OBJS=$(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.o, $(SRCS))

all: $(BINDIR) $(OBJDIR) $(BIN)

$(BIN): $(OBJS)
	$(CC) -o $(BINDIR)/$@ $^ $(LFLAGS)

$(BINDIR):
	if [ ! -d "$(BINDIR)" ]; then mkdir -p $(BINDIR); fi

$(OBJDIR):
	if [ ! -d "$(OBJDIR)" ]; then mkdir -p $(OBJDIR); fi

$(OBJDIR)/%.o : $(SRCDIR)/%.cpp
	$(CC) $(CFLAGS) -c  $< -o $@

.PHONY: clean
clean:
	rm -f $(OBJDIR)/*.o $(BINDIR)/$(BIN)

.PHONY: test
test:
	$(BINDIR)/$(BIN) $(BINDIR)/WR10 1e10
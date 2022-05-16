include config.mk


# local dependencies
DEPS += -Isrc
#LIBS += -L. -l$(SIDIS-EIC)


# assume each .cpp file has main and build corresponding .exe executable
SOURCES := $(basename $(wildcard *.cpp))
EXES := $(addsuffix .exe, $(SOURCES))


#--------------------------------------------


all: 
	@cd mstwpdf; make
	@cd src; make
	make exe

exe: $(EXES)

%.exe: %.o
	@echo "--- make executable $@"
	$(CXX) -o $@ $< ./$(SIDIS-EIC-OBJ) $(LIBS)

%.o: %.cpp
	@echo "----- build $@ -----"
	$(CXX) -c $^ -o $@ $(FLAGS) $(DEPS)

clean:
	@cd mstwpdf; make clean
	@cd src; make clean
#$(RM) $(EXES)

CXX=g++
CXXFLAGS=-std=c++17 -O2 -Wall
all: bank
bank: main.o Bank.o
    $(CXX) $(CXXFLAGS) -o bank main.o Bank.o
main.o: main.cpp Bank.h Account.h
Bank.o: Bank.cpp Bank.h Account.h
clean:
    rm -f *.o bank
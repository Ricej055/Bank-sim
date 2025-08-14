#pragma once
#include <string>
class Account {
    int id; std::string owner; double balance;
public:
    Account(int id, const std::string& owner) : id(id), owner(owner), balance(0.0) {}
    void deposit(double amount){ if(amount>0) balance+=amount; }
    bool withdraw(double amount){ if(amount>0 && amount<=balance){ balance-=amount; return true; } return false; }
    double getBalance() const { return balance; }
    int getId() const { return id; }
};

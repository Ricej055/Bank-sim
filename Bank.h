#pragma once
#include <vector>
#include <string>
#include <iostream>
#include "Account.h"
class Bank {
    std::vector<Account> accounts; int nextId{1};
public:
    int createAccount(const std::string& owner){ accounts.emplace_back(nextId, owner); return nextId++; }
    void deposit(int id,double amt){ for(auto& a:accounts) if(a.getId()==id){ a.deposit(amt); std::cout<<"Deposited\n"; return; } std::cout<<"Account not found\n"; }
    void withdraw(int id,double amt){ for(auto& a:accounts) if(a.getId()==id){ if(!a.withdraw(amt)) std::cout<<"Insufficient funds\n"; else std::cout<<"Withdrew\n"; return; } std::cout<<"Account not found\n"; }
    void showBalance(int id) const { for(const auto& a:accounts) if(a.getId()==id){ std::cout<<"Balance: $"<<a.getBalance()<<"\n"; return; } std::cout<<"Account not found\n"; }
};

#include <iostream>
#include "Bank.h"
int main(){
    Bank bank; int choice=0;
    do{
        std::cout << "\nBank Simulator\n"
                  << "1.Create  2.Deposit  3.Withdraw  4.Show  5.Exit\n> ";
        if(!(std::cin>>choice)) break;
        if(choice==1){ std::string name; std::cout<<"Name: "; std::cin>>name; int id=bank.createAccount(name); std::cout<<"Account ID "<<id<<"\n"; }
        else if(choice==2){ int id; double a; std::cout<<"ID amount: "; std::cin>>id>>a; bank.deposit(id,a); }
        else if(choice==3){ int id; double a; std::cout<<"ID amount: "; std::cin>>id>>a; bank.withdraw(id,a); }
        else if(choice==4){ int id; std::cout<<"ID: "; std::cin>>id; bank.showBalance(id); }
    }while(choice!=5);
    return 0;
}

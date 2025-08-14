$ErrorActionPreference = "Stop"
function W($P,$T){$d=Split-Path -Parent $P;if($d -and -not (Test-Path $d)){New-Item -ItemType Directory -Force -Path $d|Out-Null};$enc=New-Object System.Text.UTF8Encoding($false);[IO.File]::WriteAllText($P,$T,$enc)}
W 'CMakeLists.txt' "cmake_minimum_required(VERSION 3.16)
project(bank_simulator LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_library(banklib
  src/Account.cpp
  src/CheckingAccount.cpp
  src/SavingsAccount.cpp
  src/Bank.cpp)
target_include_directories(banklib PUBLIC include)
add_executable(bank_sim src/main.cpp)
target_link_libraries(bank_sim PRIVATE banklib)
"
W 'include/Account.h' '#pragma once
#include <string>
#include <stdexcept>
class Account{protected:int id_;std::string owner_;double balance_{0.0};public:Account(int id,std::string owner,double initial=0.0);virtual ~Account()=default;int id()const noexcept{return id_;}const std::string& owner()const noexcept{return owner_;}double balance()const noexcept{return balance_;}void deposit(double amount);virtual bool withdraw(double amount);virtual const char* type()const noexcept=0;virtual void monthlyUpdate();};'
W 'include/CheckingAccount.h' '#pragma once
#include "Account.h"
class CheckingAccount:public Account{double monthly_fee_{5.0};public:CheckingAccount(int id,std::string owner,double initial=0.0,double fee=5.0):Account(id,std::move(owner),initial),monthly_fee_(fee){}const char* type()const noexcept override{return "Checking";}void monthlyUpdate() override;};'
W 'include/SavingsAccount.h' '#pragma once
#include "Account.h"
class SavingsAccount:public Account{double annual_interest_rate_{0.02};public:SavingsAccount(int id,std::string owner,double initial=0.0,double apr=0.02):Account(id,std::move(owner),initial),annual_interest_rate_(apr){}const char* type()const noexcept override{return "Savings";}void monthlyUpdate() override;};'
W 'include/Bank.h' '#pragma once
#include <memory>
#include <unordered_map>
#include <vector>
#include <string>
#include "Account.h"
#include "CheckingAccount.h"
#include "SavingsAccount.h"
class Bank{std::unordered_map<int,std::unique_ptr<Account>> accounts_;int next_id_{1};public:int createChecking(const std::string& owner,double initial=0.0,double fee=5.0);int createSavings(const std::string& owner,double initial=0.0,double apr=0.02);Account* get(int id) noexcept;const Account* get(int id)const noexcept;bool deposit(int id,double amount);bool withdraw(int id,double amount);bool transfer(int from_id,int to_id,double amount);std::vector<const Account*> list()const;bool remove(int id);void monthlyUpdateAll();};'
W 'src/Account.cpp' '#include "Account.h"
Account::Account(int id,std::string owner,double initial):id_(id),owner_(std::move(owner)),balance_(initial){if(initial<0.0)throw std::invalid_argument("Initial balance cannot be negative");}
void Account::deposit(double amount){if(amount<=0.0)throw std::invalid_argument("Deposit amount must be positive");balance_+=amount;}
bool Account::withdraw(double amount){if(amount<=0.0)throw std::invalid_argument("Withdrawal amount must be positive");if(amount>balance_)return false;balance_-=amount;return true;}
void Account::monthlyUpdate(){}'
W 'src/CheckingAccount.cpp' '#include "CheckingAccount.h"
void CheckingAccount::monthlyUpdate(){if(monthly_fee_>0.0){if(monthly_fee_<=balance_)balance_-=monthly_fee_;else balance_=0.0;}}'
W 'src/SavingsAccount.cpp' '#include "SavingsAccount.h"
void SavingsAccount::monthlyUpdate(){if(annual_interest_rate_<=0.0)return;const double m=annual_interest_rate_/12.0;balance_+=balance_*m;}'
W 'src/Bank.cpp' '#include "Bank.h"
#include <algorithm>
int Bank::createChecking(const std::string& owner,double initial,double fee){int id=next_id_++;accounts_[id]=std::make_unique<CheckingAccount>(id,owner,initial,fee);return id;}
int Bank::createSavings(const std::string& owner,double initial,double apr){int id=next_id_++;accounts_[id]=std::make_unique<SavingsAccount>(id,owner,initial,apr);return id;}
Account* Bank::get(int id) noexcept{auto it=accounts_.find(id);return it==accounts_.end()?nullptr:it->second.get();}
const Account* Bank::get(int id)const noexcept{auto it=accounts_.find(id);return it==accounts_.end()?nullptr:it->second.get();}
bool Bank::deposit(int id,double amount){if(auto*a=get(id)){a->deposit(amount);return true;}return false;}
bool Bank::withdraw(int id,double amount){if(auto*a=get(id))return a->withdraw(amount);return false;}
bool Bank::transfer(int from_id,int to_id,double amount){if(from_id==to_id)return false;auto*src=get(from_id);auto*dst=get(to_id);if(!src||!dst)return false;if(!src->withdraw(amount))return false;try{dst->deposit(amount);}catch(...){src->deposit(amount);throw;}return true;}
std::vector<const Account*> Bank::list()const{std::vector<const Account*> v;v.reserve(accounts_.size());for(auto&kv:accounts_)v.push_back(kv.second.get());std::sort(v.begin(),v.end(),[](auto*a,auto*b){return a->id()<b->id();});return v;}
bool Bank::remove(int id){return accounts_.erase(id)>0;}
void Bank::monthlyUpdateAll(){for(auto&kv:accounts_)kv.second->monthlyUpdate();}'
W 'src/main.cpp' '#include <iostream>
#include <limits>
#include <string>
#include "Bank.h"
namespace ui{int readInt(const std::string&p){int v;while(true){std::cout<<p;if(std::cin>>v)return v;std::cin.clear();std::cin.ignore(std::numeric_limits<std::streamsize>::max(),'\n');std::cout<<"Enter a valid number.\n";}}double readDouble(const std::string&p){double v;while(true){std::cout<<p;if(std::cin>>v)return v;std::cin.clear();std::cin.ignore(std::numeric_limits<std::streamsize>::max(),'\n');std::cout<<"Enter a valid amount.\n";}}std::string readWord(const std::string&p){std::string s;std::cout<<p;std::cin>>s;return s;}}
static void list(const Bank&b){auto v=b.list();if(v.empty()){std::cout<<"No accounts.\n";return;}std::cout<<"\n#  | Type     | Owner           | Balance\n"<<"---+----------+----------------+---------\n";for(auto*a:v){std::cout<<a->id()<<"  | "<<a->type()<<" | "<<a->owner()<<"\t| $"<<a->balance()<<"\n";}}
int main(){Bank bank;while(true){std::cout<<"\n=== Bank Simulator ===\n1) List accounts\n2) Create Checking\n3) Create Savings\n4) Deposit\n5) Withdraw\n6) Transfer\n7) Monthly update\n8) Remove account\n0) Exit\n> ";int c;if(!(std::cin>>c))break;try{if(c==1){list(bank);}else if(c==2){auto owner=ui::readWord("Owner: ");double initial=ui::readDouble("Initial deposit (>=0): ");double fee=ui::readDouble("Monthly fee: ");int id=bank.createChecking(owner,initial,fee);std::cout<<"Created Checking ID "<<id<<"\n";}else if(c==3){auto owner=ui::readWord("Owner: ");double initial=ui::readDouble("Initial deposit (>=0): ");double apr=ui::readDouble("Annual interest rate (e.g., 0.02): ");int id=bank.createSavings(owner,initial,apr);std::cout<<"Created Savings ID "<<id<<"\n";}else if(c==4){int id=ui::readInt("Account ID: ");double amt=ui::readDouble("Amount: ");if(!bank.deposit(id,amt))std::cout<<"Account not found.\n";}else if(c==5){int id=ui::readInt("Account ID: ");double amt=ui::readDouble("Amount: ");if(!bank.withdraw(id,amt))std::cout<<"Insufficient funds or account not found.\n";}else if(c==6){int from=ui::readInt("From ID: ");int to=ui::readInt("To ID: ");double amt=ui::readDouble("Amount: ");if(!bank.transfer(from,to,amt))std::cout<<"Transfer failed.\n";}else if(c==7){bank.monthlyUpdateAll();std::cout<<"Monthly update applied.\n";}else if(c==8){int id=ui::readInt("Account ID: ");if(!bank.remove(id))std::cout<<"Account not found.\n";}else if(c==0){std::cout<<"Goodbye\n";break;}else{std::cout<<"Unknown option.\n";}}catch(const std::exception&e){std::cout<<"[error] "<<e.what()<<"\n";}}return 0;}'
$built=$false
try{cl /nologo /std:c++17 /EHsc src\Account.cpp src\CheckingAccount.cpp src\SavingsAccount.cpp src\Bank.cpp src\main.cpp /I include /Fe:bank_sim.exe;$built=Test-Path .\bank_sim.exe}catch{}
if(-not $built){if(Get-Command cmake -ErrorAction SilentlyContinue){cmake -S . -B build | Out-Null; cmake --build build -j | Out-Null; if(Test-Path .\build\bank_sim.exe){Write-Host 'Run: .\build\bank_sim.exe' -ForegroundColor Cyan}else{Write-Host 'Built (generator default). Check build folder.' -ForegroundColor Yellow}}else{Write-Host 'Neither MSVC (cl) nor CMake found. Open "Developer PowerShell for VS 2022" and re-run this command.' -ForegroundColor Yellow}

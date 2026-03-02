local BankAPI = require "BankAPI"
local Logger = require "Logger"

BankAPI.construction("1234", "0000", {RUB = 5000, USD = 50}, 10000, 2027)

print("Добро пожаловать! Введите номер вашей карты:")
local user_card = io.read()

print("Введите ПИН-код:")
local user_pin = io.read()

local success, message = BankAPI.verify_pin(user_card, user_pin)

if success then
    print("Какую сумму хотите снять?")
    local summ = tonumber(io.read())
    print( message)
    if BankAPI.withdraw(user_card, summ) then
        print("Операция прошла успешно")
        print("Остаток: " .. BankAPI.get_balance(user_card))
    else
        print("Ошибка: Средств недостаточно")
    end
else
    print("В доступе отказано: " .. message)
    Logger.log("WARNING", message)
end

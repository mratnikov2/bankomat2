local BankAPI = require "BankAPI"
local Logger = require "Logger"

BankAPI.construction("1234", "0000", {rub = 5000, usd = 50}, 10000, 2027)

local attempts = 3

print("--- СИСТЕМА БАНКОМАТА ЗАПУЩЕНА ---")

while attempts > 0 do
    print("\nПопыток осталось: " .. attempts)
    print("Введите номер вашей карты:")
    local user_card = io.read()

    print("Введите ПИН-код:")
    local user_pin = io.read()

    local success, message = BankAPI.verify_pin(user_card, user_pin)

    if success then
        print("\n--- ДОСТУП РАЗРЕШЕН: " .. message .. " ---")
        
        while true do
            print("\nВыберите действие:")
            print("1 - Посмотреть баланс")
            print("2 - Снять деньги")
            print("3 - Завершить сеанс")
            
            local choice = io.read()

            if choice == "1" then
                print("Валюта (rub, usd):")
                local currency = io.read()
                print("Ваш баланс: " .. BankAPI.get_balance(user_card, currency))

            elseif choice == "2" then
            print("Сумма:")
            local amount = tonumber(io.read())
            print("Валюта (rub, usd):")
            local currency = io.read()     
            if BankAPI.withdraw(user_card, amount, currency) then
                print("Успешно! Заберите наличные.")
                local log_msg = string.format("Снятие: %d %s, Карта: %s", amount, currency, user_card)
                Logger.log("TRANSACTION", log_msg)               
            else
                print("Ошибка: недостаточно средств.")
                Logger.log("ERROR", "Отказ в снятии: " .. user_card)
            end

            elseif choice == "3" then
                print("Заберите карту. До свидания!")
                os.exit()
            else
                print("Ошибка выбора. Попробуйте 1, 2 или 3.")
            end
        end
    else
       
        attempts = attempts - 1 
        print("ВНИМАНИЕ: " .. message)
        Logger.log("WARNING", "Неверный ПИН для карты: " .. user_card)
        
        if attempts == 0 then
            print("\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            print("КАРТА ЗАБЛОКИРОВАНА. ОБРАТИТЕСЬ В БАНК.")
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        end
    end
end

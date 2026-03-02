local accounts = {}
local BankAPI = {}

local rates = {
    dollar = 100,
    euro = 91,
    rub = 30,
    grn = 20,
}

local function construction(card_number, pin, balance, limit, exp_year)
    local new_table = {
        card_number = card_number,
        pin = pin,
        balance = balance,
        limit = limit,
        isLocked = false,
        attempts = 3,
        exp_year = exp_year,
    }
    accounts[card_number] = new_table
end

local function verify_pin(card_number, input_pin)
    if accounts[card_number] then
        if accounts[card_number].isLocked == true then
            return false, "Карта уже заблокирована"
        end
        if accounts[card_number].exp_year >= tonumber(os.date("%Y")) then
            if accounts[card_number].pin == input_pin and accounts[card_number].attempts >= 0 then
                accounts[card_number].attempts = 3
                return true, "Доступ разрешен"
            else
                accounts[card_number].attempts = accounts[card_number].attempts - 1
                if accounts[card_number].attempts <= 0 then
                    accounts[card_number].isLocked = true
                    return false, "Карта заблокирована. Превышен лимит попыток"
                else
                    return false, "Не верный пин код"
                end
            end
        else
            return false, "Истек срок карты"
        end
    else
        return false, "Нет такой карты"
    end
end

local function get_balance(card_number, currency)
    return accounts[card_number].balance[currency] or 0
end

local function withdraw(card_number, amount, currency)
    local target_balance = accounts[card_number].balance[currency] or 0
    
    local rub_balance = accounts[card_number].balance["rub"] or 0
    local dollar_balance = accounts[card_number].balance["dollar"] or 0
    local euro_balance = accounts[card_number].balance["euro"] or 0

    local cost_in_rub = (amount * rates[currency]) / rates["rub"]
    local cost_in_dollar = (amount * rates[currency]) / rates["dollar"]
    local cost_in_euro = (amount * rates[currency]) / rates["euro"]

    if target_balance >= amount then
        accounts[card_number].balance[currency] = target_balance - amount
        return true 
    elseif rub_balance >= cost_in_rub then
        accounts[card_number].balance["rub"] = rub_balance - cost_in_rub
        return true
    elseif dollar_balance >= cost_in_dollar then
        accounts[card_number].balance["dollar"] = dollar_balance - cost_in_dollar
        return true
    elseif euro_balance >= cost_in_euro then
        accounts[card_number].balance["euro"] = euro_balance - cost_in_euro
        return true
    else
        return false
    end
end

local function debit_cart(card_number, amount, currency)
    accounts[card_number].balance[currency]= accounts[card_number].balance[currency] or 0
    accounts[card_number].balance[currency] = accounts[card_number].balance[currency] + amount
end

BankAPI.get_balance = get_balance
BankAPI.verify_pin = verify_pin
BankAPI.withdraw = withdraw
BankAPI.construction = construction
BankAPI.debit_cart = debit_cart

return BankAPI

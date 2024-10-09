local QBCore = exports['qb-core']:GetCoreObject()

-- 處理購買物品
RegisterNetEvent('betelNut:buyItems')
AddEventHandler('betelNut:buyItems', function(item, quantity, totalPrice)
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)

    -- 檢查玩家是否有足夠的錢購買
    if Player.Functions.RemoveMoney('cash', totalPrice) then
        -- 增加購買的物品
        Player.Functions.AddItem(item, quantity)
        TriggerClientEvent('QBCore:Notify', _source, '成功購買 ' .. quantity .. ' 個 ' .. item .. '，共花費 $' .. totalPrice)
    else
        TriggerClientEvent('QBCore:Notify', _source, '現金不足，無法購買', 'error')
    end
end)

-- 處理合成檳榔
RegisterNetEvent('betelNut:craftBetelNut')
AddEventHandler('betelNut:craftBetelNut', function(recipe)
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
    local requiredItems = Config.Recipes[recipe].requires
    local canCraft = true

    -- 檢查材料
    for item, amount in pairs(requiredItems) do
        if not Player.Functions.GetItemByName(item) or Player.Functions.GetItemByName(item).amount < amount then
            canCraft = false
            break
        end
    end

    if canCraft then
        -- 移除材料並添加結果
        for item, amount in pairs(requiredItems) do
            Player.Functions.RemoveItem(item, amount)
        end
        Player.Functions.AddItem(Config.Recipes[recipe].result, 1)
        TriggerClientEvent('QBCore:Notify', _source, '成功合成 ' .. Config.Recipes[recipe].result)
    else
        TriggerClientEvent('QBCore:Notify', _source, '材料不足', 'error')
    end
end)

-- 處理檳榔使用效果
QBCore.Functions.CreateUseableItem("basic_betel_nut", function(source, item)
    TriggerClientEvent('betelNut:useItem', source, "basic_betel_nut")
end)

QBCore.Functions.CreateUseableItem("special_betel_nut", function(source, item)
    TriggerClientEvent('betelNut:useItem', source, "special_betel_nut")
end)

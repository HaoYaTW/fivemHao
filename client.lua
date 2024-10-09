local QBCore = exports['qb-core']:GetCoreObject()

-- 創建商店 NPC 並允許玩家與之互動
Citizen.CreateThread(function()
    for _, shop in pairs(Config.Shops) do
        RequestModel(shop.pedModel)
        while not HasModelLoaded(shop.pedModel) do
            Wait(500)
        end

        -- 創建 NPC
        local ped = CreatePed(4, GetHashKey(shop.pedModel), shop.location.x, shop.location.y, shop.location.z, shop.heading, false, true)
        SetEntityHeading(ped, shop.heading)
        FreezeEntityPosition(ped, true)

        -- 為商店或工作台添加 BoxZone
exports['qb-target']:AddBoxZone("shop_npc", vector3(shop.location.x, shop.location.y, shop.location.z), 1.5, 1.5, {
    name = "shop_npc",
    heading = shop.heading,
    debugPoly = false,  -- 設置為 true 以查看碰撞區範圍
    minZ = shop.location.z - 1.0,
    maxZ = shop.location.z + 1.0
}, {
    options = {
        {
            event = "betelNut:showShopMenu",
            icon = "fas fa-store",
            label = "購買檳榔",
        },
    },
    distance = 8.0  -- 設置互動距離
})

    end
end)

Citizen.CreateThread(function()
    for _, workshop in pairs(Config.Workshops) do
        RequestModel(workshop.workbench)
        while not HasModelLoaded(workshop.workbench) do
            Wait(500)
        end

        -- 創建工作台物件
        local workbench = CreateObject(GetHashKey(workshop.workbench), workshop.location.x, workshop.location.y, workshop.location.z, false, true, true)
        SetEntityHeading(workbench, workshop.heading)
        PlaceObjectOnGroundProperly(workbench)

        -- 確保物件已創建
        if DoesEntityExist(workbench) then
            print("工作台已成功創建在位置: " .. workshop.location.x .. ", " .. workshop.location.y .. ", " .. workshop.location.z)
        else
            print("工作台創建失敗，請檢查模型名稱和座標")
        end

        -- 添加工作台的目標互動
        exports['qb-target']:AddTargetEntity(workbench, {
            options = {
                {
                    event = "betelNut:showCraftingMenu",  -- 顯示檳榔合成選單
                    icon = "fas fa-tools",
                    label = "檳榔合成",
                },
            },
            distance = 3.0
        })
    end
end)

-- 顯示購買選單
RegisterNetEvent('betelNut:showShopMenu')
AddEventHandler('betelNut:showShopMenu', function()
    local shopOptions = {
        {
            header = "購買檳榔",
            isMenuHeader = true -- 設置為選單標題
        },
        {
            header = "購買基本檳榔",
            txt = "價格: $20/個",
            params = {
                event = "betelNut:inputQuantity",
                args = {
                    item = "basic_betel_nut",
                    price = 20
                }
            }
        },
        --[[{
            header = "購買特殊檳榔",
            txt = "價格: $10/個",
            params = {
                event = "betelNut:inputQuantity",
                args = {
                    item = "special_betel_nut",
                    price = 500
                }
            }
        },]]
        --[[{
            header = "購買材料",
            txt = "購買檳榔製作材料",
            params = {
                event = "betelNut:showMaterialMenu"  -- 顯示材料選單
            }
        },]]
        {
            header = "❌ 關閉選單",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(shopOptions)
end)

-- 顯示材料選單
RegisterNetEvent('betelNut:showMaterialMenu')
AddEventHandler('betelNut:showMaterialMenu', function()
    local materialOptions = {}

    -- 遍歷材料
    for material, data in pairs(Config.Materials) do
        table.insert(materialOptions, {
            header = "購買 " .. material,
            txt = "價格: $" .. data.price .. "/個",
            params = {
                event = "betelNut:inputQuantity",
                args = {
                    item = material,
                    price = data.price
                }
            }
        })
    end

    table.insert(materialOptions, {
        header = "❌ 返回上層",
        params = {
            event = "betelNut:showShopMenu"
        }
    })

    exports['qb-menu']:openMenu(materialOptions)
end)

-- 輸入購買數量
RegisterNetEvent('betelNut:inputQuantity')
AddEventHandler('betelNut:inputQuantity', function(data)
    local dialog = exports['qb-input']:ShowInput({
        header = "輸入購買數量",
        submitText = "確認購買",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'quantity',
                text = '數量'
            }
        }
    })

    if dialog then
        local quantity = tonumber(dialog.quantity)
        if quantity and quantity > 0 then
            -- 計算總價
            local totalPrice = data.price * quantity
            -- 傳送到服務器進行購買
            TriggerServerEvent('betelNut:buyItems', data.item, quantity, totalPrice)
        else
            TriggerEvent('QBCore:Notify', "請輸入有效的數量", "error")
        end
    end
end)

-- 顯示合成選單
RegisterNetEvent('betelNut:showCraftingMenu')
AddEventHandler('betelNut:showCraftingMenu', function()
    local craftingOptions = {
        {
            header = "合成檳榔",
            isMenuHeader = true -- 設置為選單標題
        },
        {
            header = "合成基本檳榔",
            txt = "需要 2 片檳榔葉和 1 份石灰",
            params = {
                event = "betelNut:craftItem",
                args = {
                    recipe = "basic_betel_nut"
                }
            }
        },
        {
            header = "合成特殊檳榔",
            txt = "需要 3 片檳榔葉、2 份石灰、1 份香料和 1 份糖",
            params = {
                event = "betelNut:craftItem",
                args = {
                    recipe = "special_betel_nut"
                }
            }
        },
        {
            header = "❌ 關閉選單",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(craftingOptions)
end)

-- 購買物品事件
RegisterNetEvent('betelNut:buyItem')
AddEventHandler('betelNut:buyItem', function(data)
    local item = data.item
    TriggerServerEvent('betelNut:buyMaterials', item)  -- 觸發服務器購買邏輯
end)

-- 合成物品事件
RegisterNetEvent('betelNut:craftItem')
AddEventHandler('betelNut:craftItem', function(data)
    local recipe = data.recipe
    TriggerServerEvent('betelNut:craftBetelNut', recipe)  -- 觸發服務器合成邏輯
end)


-- 使用檳榔的效果並播放吃東西的動作
RegisterNetEvent('betelNut:useItem')
AddEventHandler('betelNut:useItem', function(itemName)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)  -- 玩家最大血量，通常為 200
    local currentHealth = GetEntityHealth(playerPed)  -- 當前血量

    -- 播放吃東西的動畫
    RequestAnimDict("mp_player_inteat@burger")  -- 載入動畫字典
    while not HasAnimDictLoaded("mp_player_inteat@burger") do
        Wait(100)
    end
    TaskPlayAnim(playerPed, "mp_player_inteat@burger", "mp_player_int_eat_burger", 8.0, -8.0, 3000, 49, 0, false, false, false)

    -- 根據檳榔類型處理效果
    if itemName == "basic_betel_nut" then
        -- 基本檳榔效果：增加 20% 的血量
        local newHealth = currentHealth + (maxHealth * 0.2)
        if newHealth > maxHealth then
            newHealth = maxHealth  -- 確保血量不超過最大值
        end
        SetEntityHealth(playerPed, newHealth)
        TriggerEvent('QBCore:Notify', "你吃了基本檳榔，增加了 20% 血量！")
        TriggerServerEvent('QBCore:Server:RemoveItem', 'basic_betel_nut', 1)  -- 使用道具後刪除

    elseif itemName == "special_betel_nut" then
        -- 特殊檳榔效果：增加 50% 的血量
        local newHealth = currentHealth + (maxHealth * 0.5)
        if newHealth > maxHealth then
            newHealth = maxHealth  -- 確保血量不超過最大值
        end
        SetEntityHealth(playerPed, newHealth)
        TriggerEvent('QBCore:Notify', "你吃了特殊檳榔，增加了 50% 血量且5分鐘內耐力不會減少！")
        TriggerServerEvent('QBCore:Server:RemoveItem', 'special_betel_nut', 1)  -- 使用道具後刪除

        -- 防止耐力消耗並維持 5 分鐘
        Citizen.CreateThread(function()
            local endTime = GetGameTimer() + (5 * 60 * 1000)  -- 5 分鐘的計時器

            while GetGameTimer() < endTime do
                -- 防止玩家在跑步時消耗耐力
                ResetPlayerStamina(PlayerId())  -- 重置玩家的耐力消耗
                Wait(100)  -- 每 100 毫秒檢查並重置耐力
            end

            -- 提醒玩家效果結束
            TriggerEvent('QBCore:Notify', "你的特殊檳榔效果已結束，耐力恢復正常！")
        end)
    end

    -- 停止吃東西的動作動畫
    Wait(3000)  -- 動作時間3秒
    ClearPedTasks(playerPed)  -- 清除動畫
end)


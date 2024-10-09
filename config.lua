Config = {}

-- 商店位置和 NPC 模型
Config.Shops = {
    {location = vector3(-1109.7300, -1694.0411, 3.5646), heading = 306.2333, pedModel = 'a_f_y_beach_01'},  -- 比基尼女郎
}

-- 工作台位置和模型
--[[Config.Workshops = {
    {location = vector3(212.5890, -926.8354, 30.2920), heading = 52.9271, workbench = 'prop_workbench_01'},  -- 工作台
}]]

-- 材料和價格
Config.Materials = {
    betel_leaf = {price = 5},
    lime = {price = 3},
    spice = {price = 2},
    sugar = {price = 1},
}

-- 合成配方
Config.Recipes = {
    basic_betel_nut = {
        requires = {betel_leaf = 2, lime = 1},  -- 基本檳榔的材料
        result = "basic_betel_nut"  -- 合成結果
    },
    special_betel_nut = {
        requires = {betel_leaf = 3, lime = 2, spice = 1, sugar = 1},  -- 特殊檳榔的材料
        result = "special_betel_nut"  -- 合成結果
    },
}


-- 道具定義
Config.Items = {
    ['basic_betel_nut'] = {label = '基本檳榔', weight = 100, type = 'item', image = 'betel_nut_basic.png', description = '一個普通的檳榔。'},
    ['special_betel_nut'] = {label = '特殊檳榔', weight = 100, type = 'item', image = 'betel_nut_special.png', description = '一個特別調製的檳榔，增加能量。'},
}

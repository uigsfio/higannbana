-- 初始化隐藏饰品
VSB = VSB or {}

function HideWearables( event )
 local hero = event.caster
 local ability = event.ability
 local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
 print("Hiding Wearables")
 --hero:AddNoDraw() -- Doesn't work on classname dota_item_wearable
 
 hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
 hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            if string.find(modelName, "invisiblebox") == nil then
             -- Add the original model name to revert later
             table.insert(hero.wearableNames,modelName)
             print("Hidden "..modelName.."")
 
             -- Set model invisible
             model:SetModel("models/development/invisiblebox.vmdl")
             table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
        if model ~= nil then
         print("Next Peer:" .. model:GetModelName())
        end
    end
end

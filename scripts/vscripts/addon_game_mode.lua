-- 为了死宅的荣耀（咦
-- 好无聊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊好累啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊

----------------------------------------------------------------------------
--全局变量定义
_G.BASE_LEVEL = 0

----------------------------------------------------------------------------
--唤醒文件

-- 刷怪核心
require('core/CFRoundThinker')
require('core/CFSpawner')
--require('items/general_item')
--require( 'vsb_set' )

----------------------------------------------------------------------------
--设置游戏模式

if CHigannbanaGameMode == nil then
   _G.CHigannbanaGameMode = class({})
end

----------------------------------------------------------------------------
--预载入变量定义
local function PrecacheModel(model, context )
    PrecacheResource( "model", model, context )
end

local function PrecacheSound(sound, context )
    PrecacheResource( "soundfile", sound, context)
end

local function PrecacheParticle(particle, context )
    PrecacheResource( "particle",  particle, context)
end
----------------------------------------------------------------------------
--预载入
function Precache( context )

PrecacheParticle( "particles/units/heroes/hero_invoker/invoker_ice_wall_shards.vpcf", context )
PrecacheParticle( "particles/units/heroes/hero_invoker/invoker_ice_wall_icicle.vpcf", context )
PrecacheParticle( "particles/units/heroes/hero_undying/undying_tombstone_spawn.vpcf", context)
PrecacheParticle( "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", context)
PrecacheParticle( "particles/saber/saber_exc.vpcf", context)
PrecacheParticle( "particles/saber/saber_wind.vpcf", context)

-- 音效文件
PrecacheSound( "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context )
PrecacheSound( "soundevents/game_sounds_vo_nyx_assassin.vsndevts", context )
PrecacheSound( "soundevents/saber_sounds.vsndevts", context )

-- 小兵的统一音效
PrecacheSound( 'soundevents/game_sounds_heroes/game_sounds_undying.vsndevts', context)
PrecacheSound( 'soundevents/game_sounds_creeps.vsndevts', context )

PrecacheUnitByNameAsync('npc_dota_vsb_base', function() print('precache finished') end)
PrecacheUnitByNameAsync('npc_dota_hero_invoker', function() print('precache finished') end)

  --从KV文件统一载入小怪模型
    local unit_kv = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    if unit_kv then
        for unit_name,keys in pairs(unit_kv) do
            print("precacheing resource for unit"..unit_name)
            if type(keys) == "table" then
                if keys.Model then
                    print("precacheing model"..keys.Model)
                    PrecacheModel(keys.Model, context )
                end
            end
        end
    end

end

----------------------------------------------------------------------------
--游戏模式初始化
function Activate()
  GameRules.Higannbana = CHigannbanaGameMode()
  GameRules.Higannbana:InitGameMode()
end

----------------------------------------------------------------------------
-- 设置属于游戏模式的相关规则，并且开启循环计时器
function CHigannbanaGameMode:InitGameMode()

  print( "Higannbana is loaded." )
  -- 设定游戏规则的相关参数
  MAX_LEVEL = 200

  -- 设置每级升级所需经验
  XP_PER_LEVEL_TABLE = {}
  for i=1,MAX_LEVEL do
    XP_PER_LEVEL_TABLE[i] = i * i * 50
  end

  -- GameRules:SetHideKillMessageHeaders( true )
  -- 隐藏顶部击杀（虽然不隐藏也不会出现就是了，以防万一）  更新：TM并没有卵用

  -- GameRules:SetUseUniversalShopMode( true )
  -- 设定可否使用全地图商店模式（注释掉看情况再说）

  --设置队伍人数

  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )

  GameRules:SetSameHeroSelectionEnabled( false )
  -- 设定是否可以选择相同英雄
  GameRules:SetPostGameTime( 60.0 )
  -- 设定游戏结束后在分数面板的停留时间
  GameRules:SetUseCustomHeroXPValues( true )
  -- 是否使用自定义的英雄经验
  GameRules:SetGoldPerTick( 0 )
  -- 关闭工资
  GameRules:SetTreeRegrowTime( 60 )
  -- 树木重生时间
  GameRules:SetHeroSelectionTime( 30 )
  -- 英雄选择时间
  GameRules:SetPreGameTime( 10 )
  -- 游戏准备时间
  GameRules:SetFirstBloodActive( false )
  -- 关闭一血提示
  GameRules:SetUseBaseGoldBountyOnHeroes( true )
  -- 关闭英雄特殊奖励
--GameRules:SetHeroRespawnEnabled( false )
  -- 关闭默认复活规则
  GameRules:SetHideKillMessageHeaders( true )
  -- 关闭击杀提示

  -- 关闭死亡金钱惩罚
  GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
  -- 禁用推荐装备，目前这个API已经修复
  GameRules:GetGameModeEntity():SetRecommendedItemsDisabled( true )
  -- 设定镜头距离的大小，默认为1134
  GameRules:GetGameModeEntity():SetCameraDistanceOverride( 1300 )
  -- 提高泉水效果
  GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 20 )
  GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 20 )
  GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 30 )
  -- 设定使用自定义的买活费，买活冷却，设定是否能买活，自定义复活时间参数
  GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled( true )
  GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled( true )
  GameRules:GetGameModeEntity():SetBuybackEnabled( false )
  GameRules:GetGameModeEntity():SetFixedRespawnTime( 10 )
  -- 设定顶部的分数是否为自定义
  GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride ( true )
  -- 设定是否使用自定义的英雄等级经验
  GameRules:GetGameModeEntity():SetUseCustomHeroLevels ( true )
  GameRules:GetGameModeEntity():SetCustomHeroMaxLevel ( MAX_LEVEL )
  GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

  -- 设定GAMEMODE这个实体的循环函数，0.1秒执行一次
  GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 0.1 )

  -- 使用Dynamic_Wrap的好处是可以在控制台输入 developer 1之后，控制台显示一些额外的信息
--ListenToGameEvent("entity_killed", Dynamic_Wrap(CHigannbanaGameMode, 'OnEntityKilled'), self)
  -- 监听单位被击杀的事件 
--ListenToGameEvent("player_say", Dynamic_Wrap(CHigannbanaGameMode, "PlayerSay"), self)
  -- 监听玩家聊天事件，这可以用来监听一些指令
--ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(CHigannbanaGameMode, "AbilityUsed"), self)
  -- 玩家使用了某个技能事件
--ListenToGameEvent("npc_spawned", Dynamic_Wrap(CHigannbanaGameMode, "OnNPCSpawned"), self)
  -- 监听单位重生或者创建事件
--ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHigannbanaGameMode, "OnGameRulesStateChange" ), self )
  -- 监听游戏进度
  ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap( CHigannbanaGameMode, 'OnPlayerGainedLevel' ), self) 
  -- 监听英雄升级
  --ListenToGameEvent("dota_item_purchased", Dynamic_Wrap( CHigannbanaGameMode, 'OnItemPurchased' ), self)
  -- 监听物品购买

  -- 产生随机数种子，主要是为了程序中的随机数考虑
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  createbase("custom_base")

  -- 初始化刷怪器
  CFRoundThinker:InitPara()

end

----------------------------------------------------------------------------------
--计时器

function CHigannbanaGameMode:OnThink()
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    CFRoundThinker:Think()
  elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return nil
  end
    return 0.1
end

----------------------------------------------------------------------------------
--监听游戏进度设置玩家组等变量
function createbase(units)
        -- 查找基地位置
        local _Base_Dummy = Entities:FindByName( nil , units )
        local _cbase = _Base_Dummy:GetAbsOrigin()
        -- 创建基地
        _G.VSB_BASE = CreateUnitByName( 'npc_dota_vsb_base' , _cbase , false , nil , nil , DOTA_TEAM_GOODGUYS )
        -- 移除基地无敌
        VSB_BASE:RemoveModifierByName('modifier_invulnerable')
        GameRules:SetOverlayHealthBarUnit( VSB_BASE,2 )
        print( 'fuck volvo' )
        --设置玩家组
        PlayerStates = {}

        for i=0,9 do
          PlayerStates[i]={} --玩家数据组
          PlayerStates[i]['HigannbanaPoint']=0 --初始化彼岸点
          print( 'Player OK' )
        end
end
-------------------------------------------------------------------------------------------------------------------
-- 监听超过25级
function CHigannbanaGameMode:OnPlayerGainedLevel(keys)
    print("ON PLAYER GAIN LEVEL CALLED",keys.nPlayerID,keys.level)
    DeepPrintTable(keys)
    local hero = EntIndexToHScript(keys.player):GetAssignedHero()
    local nLevel = hero:GetLevel()
    -- 如果等级超过25级，不给技能点
    if nLevel > 25 then
        hero:SetAbilityPoints(hero:GetAbilityPoints() - 1)
    end
end
-------------------------------------------------------------------------------------------------------------------
-- 在CFSpawner调用的游戏结束，TODO，以后可以修改
function CHigannbanaGameMode:FinishedGame()
    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS) 
    GameRules:SetSafeToLeave(true)
end

--------------------------------------------------------------------------------------------------------------------
--基地升级
function baselvlup(keys)
    DeepPrintTable(keys)
    local caster=keys.caster
    pid=caster:GetPlayerOwnerID()
      -- 如果已满50次，显示错误信息，并退回金钱
      if BASE_LEVEL >= 50 then
        FireGameEvent('show_center_message',
    {
        message = "遗迹已到改修上限",
        duration = 1
    })
        caster:ModifyGold( 5000,true,0 )
      else
        BASE_LEVEL = BASE_LEVEL + 1
        VSB_BASE:CreatureLevelUp( 1 ) 
        local baselvl = VSB_BASE:GetLevel() 
        print(baselvl)
      end
end
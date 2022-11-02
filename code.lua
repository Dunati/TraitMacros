local TraitMacros = CreateFrame("Frame")

local EventHandlers = {}
local deferred = false
local inCombat = InCombatLockdown()
local inUpdate = false
local timer

TraitMacros:SetScript("OnEvent", function(self, event, ...)
    EventHandlers[event](self, event, arg)
end)


local function HasTrait(node_id, entry, ranks, active_config)
    local node_info = C_Traits.GetNodeInfo(active_config, node_id)
    if ranks:len() == 0 then
        ranks = 1
    else
        ranks = tonumber(ranks)
    end
    local entry_len = entry:len()
    if entry_len > 1 then
        local active = node_info.activeEntry
        if active then
            return tonumber(entry) == active.entryID and active.rank >= ranks
        end
        return false
    elseif entry_len == 1 then
        ranks = tonumber(entry)
    end
    return node_info and node_info.ranksPurchased >= ranks
end

local function UpdateMacro(i, active_config)
    local name, icon, body = GetMacroInfo(i)
    local original = body
    for no, negate, node, separator, entry, separator2, ranks in (original:gmatch("(%a*)talent:(!?)(%d+)(/?)(%d*)(/?)(%d*)")) do
        local node_id = tonumber(node)
        local invert = negate == '!'
        local talent = "talent:"
        
        if HasTrait(node_id, entry, ranks, active_config) ~= invert then
            talent = "notalent:"
        end
        
        local s = no .. "talent:" .. negate .. node .. separator .. entry .. separator2 .. ranks
        
        local r = talent .. negate .. node .. separator .. entry .. separator2 .. ranks
        
        body = body:gsub(s, r, 1)
    end
    
    if body ~= original then
        if body:len() > 255 then
            print("Macro", name, "length would exceed 255 characters")
        else
            EditMacro(i, nil, nil, body, 1, nil)
        end
    end
end

local function UpdateTraitMacros(...)
    if inUpdate then return end
    inCombat = InCombatLockdown()
    if inCombat or C_ChallengeMode.IsChallengeModeActive() then
        deferred = true
        return
    end
    inUpdate = true
    
    local active_config = C_ClassTalents.GetActiveConfigID()
    
    local shared, character = GetNumMacros()
    for i = 1, shared do
        UpdateMacro(i, active_config)
    end
    
    for i = 1, character do
        UpdateMacro(i + 120, active_config)
    end
    
    inUpdate = false
end

local function QueueUpdate()
    if timer and not timer:IsCancelled() then timer:Cancel() end
    timer = C_Timer.NewTimer(0.5, UpdateTraitMacros)
end

EventHandlers["TRAIT_CONFIG_CREATED"] = QueueUpdate
EventHandlers["ACTIVE_COMBAT_CONFIG_CHANGED"] = QueueUpdate
EventHandlers["PLAYER_REGEN_ENABLED"] = QueueUpdate
EventHandlers["PLAYER_REGEN_DISABLED"] = QueueUpdate
EventHandlers["STARTER_BUILD_ACTIVATION_FAILED"] = QueueUpdate
EventHandlers["TRAIT_CONFIG_DELETED"] = QueueUpdate
EventHandlers["TRAIT_CONFIG_UPDATED"] = QueueUpdate
EventHandlers["PLAYER_LOGIN"] = QueueUpdate
EventHandlers["CHALLENGE_MODE_COMPLETED"] = QueueUpdate
EventHandlers["CHALLENGE_MODE_RESET"] = QueueUpdate

EventHandlers["PLAYER_REGEN_DISABLED"] = function()
    inCombat = true
end

EventHandlers["PLAYER_REGEN_ENABLED"] = function()
    inCombat = InCombatLockdown() or C_ChallengeMode.IsChallengeModeActive()
    if not incombat and deferred then
        QueueUpdate()
    end
end

EventHandlers["UPDATE_MACROS"] = function()
    if not inUpdate then QueueUpdate() end
end

for k in pairs(EventHandlers) do
    TraitMacros:RegisterEvent(k)
end

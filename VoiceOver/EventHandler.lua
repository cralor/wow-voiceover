setfenv(1, select(2, ...))
VoiceOverEventHandler = {}
VoiceOverEventHandler.__index = VoiceOverEventHandler

local ADDON_NAME = ...

function VoiceOverEventHandler:new(soundQueue, questOverlayUI)
    local eventHandler = {}
    setmetatable(eventHandler, VoiceOverEventHandler)

    eventHandler.soundQueue = soundQueue
    eventHandler.frame = CreateFrame("FRAME", "VoiceOver")
    eventHandler.questOverlayUI = questOverlayUI

    return eventHandler
end

function VoiceOverEventHandler:RegisterEvents()
    self.frame:RegisterEvent("ADDON_LOADED")
    self.frame:RegisterEvent("QUEST_DETAIL")
    self.frame:RegisterEvent("GOSSIP_SHOW")
    self.frame:RegisterEvent("QUEST_COMPLETE")
    -- self.frame:RegisterEvent("QUEST_PROGRESS")
    local eventHandler = self
    self.frame:SetScript("OnEvent", function(self, event, ...)
        eventHandler[event](eventHandler, ...)
    end)

    hooksecurefunc("AbandonQuest", function()
        local questName = GetAbandonQuestName()
        local soundsToRemove = {}
        for _, soundData in pairs(self.soundQueue.sounds) do
            if soundData.title == questName then
                table.insert(soundsToRemove, soundData)
            end
        end

        for _, soundData in pairs(soundsToRemove) do
            self.soundQueue:removeSoundFromQueue(soundData)
        end
    end)

    hooksecurefunc("QuestLog_Update", function()
        self.questOverlayUI:updateQuestOverlayUI()
    end)
end

function VoiceOverEventHandler:ADDON_LOADED(addon)
    if addon == ADDON_NAME then
        self.soundQueue.ui.refreshSettings()
    end
end

function VoiceOverEventHandler:QUEST_DETAIL()
    local questId = GetQuestID()
    local questTitle = GetTitleText()
    local questText = GetQuestText()
    local guid = UnitGUID("npc") or UnitGUID("target")
    local targetName = UnitName("npc") or UnitName("target")
    -- print("QUEST_DETAIL", questId, questTitle);
    local soundData = {
        ["fileName"] = questId .. "-accept",
        ["questId"] = questId,
        ["title"] = format("%s %s", VoiceOverUtils:getEmbeddedIcon("detail"), questTitle),
        ["fullTitle"] = format("|cFFFFFFFF%s|r|n%s %s", targetName, VoiceOverUtils:getEmbeddedIcon("detail"), questTitle),
        ["text"] = questText,
        ["unitGuid"] = guid
    }
    self.soundQueue:addSoundToQueue(soundData)
end

function VoiceOverEventHandler:QUEST_COMPLETE()
    local questId = GetQuestID()
    local questTitle = GetTitleText()
    local questText = GetRewardText()
    local guid = UnitGUID("npc") or UnitGUID("target")
    local targetName = UnitName("npc") or UnitName("target")
    -- print("QUEST_COMPLETE", questId, questTitle);
    local soundData = {
        ["fileName"] = questId .. "-complete",
        ["questId"] = questId,
        ["title"] = format("%s %s", VoiceOverUtils:getEmbeddedIcon("reward"), questTitle),
        ["fullTitle"] = format("|cFFFFFFFF%s|r|n%s %s", targetName, VoiceOverUtils:getEmbeddedIcon("reward"), questTitle),
        ["text"] = questText,
        ["unitGuid"] = guid
    }
    self.soundQueue:addSoundToQueue(soundData)
end

function VoiceOverEventHandler:GOSSIP_SHOW()
    local gossipText = GetGossipText()
    local guid = UnitGUID("npc") or UnitGUID("target")
    local targetName = UnitName("npc") or UnitName("target")
    -- print("GOSSIP_SHOW", guid, targetName);
    local soundData = {
        ["title"] = targetName,
        ["text"] = gossipText,
        ["unitGuid"] = guid
    }
    VoiceOverUtils:addGossipFileName(soundData)
    self.soundQueue:addSoundToQueue(soundData)
end

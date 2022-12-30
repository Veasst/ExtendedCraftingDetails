local function getCurrentRecipeDifficultyMultipliers()
    local maxQuality = ProfessionsFrame.CraftingPage.SchematicForm.currentRecipeInfo.maxQuality;
    local multipliers = {};
    if maxQuality == 3 then
        multipliers = {0, 0.5, 1};
    elseif maxQuality == 5 then
        multipliers = {0, 0.2, 0.5, 0.8, 1};
    end
    return multipliers;
end

local function getItemTier(itemID)
    local _, itemLink = GetItemInfo(itemID);
    local itemTierText = itemLink:match("Tier%d");
    if not itemTierText then
        return 0;
    end
    return tonumber(itemTierText:match("%d"));
end

local function getBonusFromCurrentMats()
    local quantity = {0,0,0};
    for _, allocations in ProfessionsFrame.CraftingPage.SchematicForm.transaction:EnumerateAllAllocations() do
        local allocs = allocations.allocs;
        for _, alloc in ipairs(allocs) do
            local itemTier = getItemTier(alloc.reagent.itemID);
            if itemTier ~= 0 then
                quantity[itemTier] = quantity[itemTier] + alloc.quantity;
            end
        end
	end

    local baseDifficultyValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.baseValue;
    local accumulatedQuantity = quantity[1] + quantity[2] + quantity[3];
    if accumulatedQuantity == 0 then
        return 0;
    end
    return (quantity[2] * baseDifficultyValue / 8 + quantity[3] * baseDifficultyValue / 4) / accumulatedQuantity;
end

-- difficulty tooltip
local oldOnEnterDifficultyStatLine = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.OnEnter;
ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine:SetScript("OnEnter", function(self)
    oldOnEnterDifficultyStatLine(self);
    GameTooltip_AddBlankLineToTooltip(GameTooltip);

    local baseValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.baseValue;
    local multipliers = getCurrentRecipeDifficultyMultipliers();
    for i=1,#multipliers do
        local rankIcon = CreateAtlasMarkup(Professions.GetIconForQuality(i), 20, 20);
        local rankDifficulty = baseValue*multipliers[i];
        GameTooltip_AddNormalLine(GameTooltip, rankIcon.." - "..rankDifficulty);
    end
    GameTooltip:Show();
end);

-- skill tooltip
local oldOnEnterSkillStatLine = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.OnEnter;
ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine:SetScript("OnEnter", function(self)
    oldOnEnterSkillStatLine(self);
    GameTooltip_AddBlankLineToTooltip(GameTooltip);

    local baseDifficultyValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.baseValue;
    local baseSkillValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.baseValue;
    local bonusSkillValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.bonusValue;
    local baseSkill = baseSkillValue + bonusSkillValue - getBonusFromCurrentMats();
    local multipliers = getCurrentRecipeDifficultyMultipliers();

    local bonusFromMats = {0, baseDifficultyValue / 8, baseDifficultyValue / 4};
    for i=1,3 do
        local rankIcon = CreateAtlasMarkup(Professions.GetIconForQuality(i), 20, 20);
        local craftQuality = 1;
        local craftSkill = baseSkill + bonusFromMats[i];
        for i=1,#multipliers do
            local rankDifficulty = baseDifficultyValue*multipliers[i];
            if craftSkill >= rankDifficulty then
                craftQuality = i;
            else
                break;
            end
        end
        local craftRankIcon = CreateAtlasMarkup(Professions.GetIconForQuality(craftQuality), 20, 20);
        GameTooltip_AddNormalLine(GameTooltip, rankIcon.." - "..math.floor(craftSkill).." - will craft "..craftRankIcon);
    end
    GameTooltip:Show();
end);

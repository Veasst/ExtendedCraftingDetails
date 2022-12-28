local oldOnEnterDifficultyStatLine = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.OnEnter;

ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine:SetScript("OnEnter", function(self)
    oldOnEnterDifficultyStatLine(self);
    GameTooltip_AddBlankLineToTooltip(GameTooltip);

    local baseValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.baseValue;
    local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm.currentRecipeInfo;
    local maxQuality = recipeInfo.maxQuality;
    local multipliers = {};
    if maxQuality == 3 then
        multipliers = {0, 0.5, 1};
    elseif maxQuality == 5 then
        multipliers = {0, 0.2, 0.5, 0.8, 1};
    end
    for i=1,#multipliers do
        local rankIcon = CreateAtlasMarkup(Professions.GetIconForQuality(i), 20, 20);
        local rankDifficulty = baseValue*multipliers[i];
        GameTooltip_AddNormalLine(GameTooltip, rankIcon.." - "..rankDifficulty);
    end
    GameTooltip:Show();
end);

local oldOnEnterSkillStatLine = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.OnEnter;

ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine:SetScript("OnEnter", function(self)
    oldOnEnterSkillStatLine(self);

    local baseDifficultyValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.DifficultyStatLine.baseValue;

    local maxRankMats = 1;
    for i, child in ipairs({ProfessionsFrame.CraftingPage.SchematicForm.Reagents:GetChildren()}) do
        if child.Button and child.Button.QualityOverlay then
            local nameText = child.nameText;
            local provided, required = nameText:match("(%d+)/(%d+)");
            if provided and required and tonumber(provided) >= tonumber(required) then
                local qualityAtlas = child.Button.QualityOverlay:GetAtlas();
                if qualityAtlas then
                    local quality = tonumber(qualityAtlas:match("Tier%d"):match("%d"));
                    if quality > maxRankMats then
                        maxRankMats = quality;
                    end
                end
            end
        end
    end
    local baseSkillValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.baseValue;
    local bonusSkillValue = ProfessionsFrame.CraftingPage.SchematicForm.Details.StatLines.SkillStatLine.bonusValue;

    local bonusFromMats = {0, baseDifficultyValue / 8, baseDifficultyValue / 4};
    local baseSkill = baseSkillValue + bonusSkillValue - bonusFromMats[maxRankMats];

    local recipeInfo = ProfessionsFrame.CraftingPage.SchematicForm.currentRecipeInfo;
    local maxQuality = recipeInfo.maxQuality;
    local multipliers = {};
    if maxQuality == 3 then
        multipliers = {0, 0.5, 1};
    elseif maxQuality == 5 then
        multipliers = {0, 0.2, 0.5, 0.8, 1};
    end

    GameTooltip_AddBlankLineToTooltip(GameTooltip);

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
        GameTooltip_AddNormalLine(GameTooltip, rankIcon.." - "..craftSkill.." - will craft "..craftRankIcon);
    end
    GameTooltip:Show();
end);

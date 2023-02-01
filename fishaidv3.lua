_addon.author   = 'Thorny';
_addon.name     = 'FishAid';
_addon.version  = '1.0';

require 'common'

local config = {
    Font = {
        family = 'Arial',
        size = 16,
        color = 0xFFFFFFFF,
        position = { 0, 0 },
        bgcolor = 0x80000000,
        bgvisible = true
    }
};

local state = {
    Active = false,
    Settings = config,
};

local hookMessages = {
    { message='Something caught the hook!!!', hook='Large Fish', color='|cFF00FF00|', logcolor=204 },
    { message='Something caught the hook!', hook='Small Fish', color='|cFF00FF00|', logcolor=204 },
    { message='You feel something pulling at your line.', hook='Item', color='|cFF999900|', logcolor=141 },
    { message='Something clamps onto your line ferociously!', hook='Monster', color='|cFF8b0000|', logcolor=167 },
};

local feelMessages = {
    { message='You have a good feeling about this one!', feel='Good', color='|cFF00FF00|', logcolor=204 },
    { message='You have a bad feeling about this one.', feel='Bad', color='|cFF999900|', logcolor=141 },
    { message='You have a terrible feeling about this one...', feel='Terrible', color='|cFF8B0000|', logcolor=167 },
    { message='You don\'t know if you have enough skill to reel this one in.', feel='Skill[Don\'t Know]', color='|cFF00FF00|', logcolor=204 },
    { message='You\'re fairly sure you don\'t have enough skill to reel this one in.', feel='Skill[Fairly Sure]', color='|cFF999900|', logcolor=141 },
    { message='You\'re positive you don\'t have enough skill to reel this one in!', feel='Skill[Positive]', color='|cFF8B0000|', logcolor=167 },
};

ashita.register_event('load', function()
    state.Settings = ashita.settings.load_merged(_addon.path .. 'settings/settings.json', state.Settings);

    local f = AshitaCore:GetFontManager():Create('__fishaid_addon');
    f:SetColor(state.Settings.Font.color);
    f:SetFontFamily(state.Settings.Font.family);
    f:SetFontHeight(state.Settings.Font.size);
    f:SetBold(false);
    f:SetPositionX(state.Settings.Font.position[1]);
    f:SetPositionY(state.Settings.Font.position[2]);
    f:SetVisibility(true);
    f:GetBackground():SetColor(state.Settings.Font.bgcolor);
    f:GetBackground():SetVisibility(state.Settings.Font.bgvisible);
    state.Font = f;
end);

ashita.register_event('unload', function()
    AshitaCore:GetFontManager():Delete(state.Font:GetAlias());
end);


ashita.register_event('incoming_packet', function(id, size, data)
    if (id == 0x00A) then
        state.Active = false;
    end

    if (id == 0x037) then
        if (struct.unpack('B', data, 0x30 + 1) == 0) then
            state.Active = false;
        end
    end
    
    return false;
end);

ashita.register_event('incoming_text', function(mode, chat)
    for _,entry in ipairs(hookMessages) do
        if (string.match(chat, entry.message) ~= nil) then
            state.Feel = 'Unknown';
            state.FeelColor = '|cFF999900|';
            state.Fish = entry.hook;
            state.FishColor = entry.color;
            state.Active = true;
            AshitaCore:GetChatManager():AddChatMessage(entry.logcolor, chat);
            return true;
        end
    end
    
    for _,entry in ipairs(feelMessages) do
        if (string.match(chat, entry.message) ~= nil) then
            state.Feel = entry.feel;
            state.FeelColor = entry.color;
            AshitaCore:GetChatManager():AddChatMessage(entry.logcolor, chat);
            return true;
        end
    end
    
    return false;
end);

ashita.register_event('render', function()
    if (state.Font:GetPositionX() ~= state.Settings.Font.position[1]) or (state.Font:GetPositionY() ~= state.Settings.Font.position[2]) then
        state.Settings.Font.position[1] = state.Font:GetPositionX();
        state.Settings.Font.position[2] = state.Font:GetPositionY();
        ashita.settings.save(_addon.path .. 'settings/settings.json', state.Settings);
    end
    
    if (state.Active == true) then
        state.Font:SetText(string.format('Fish:%s%s|r Feeling:%s%s|r', state.FishColor, state.Fish, state.FeelColor, state.Feel));
        state.Font:SetVisibility(true);
    else
        state.Font:SetVisibility(false);
    end
end);
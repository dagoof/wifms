SLASH_WIFMS1 = '/wifms'

local frame, events = CreateFrame('FRAME'), { }
local WIFMS_WAITING = false
local _cnst = {
    PLAYER = 'Player',
    URL = 'wifms.dagoof.net?'
}

function get_who_names()
    local character = GetUnitName(_cnst.PLAYER)
    local others, other = { }, nil
    for i = 1, GetNumWhoResults() do
        other = select(1, GetWhoInfo(i))
        table.insert(others, select(1, other))
    end
    return others
end

function get_others_querystrings()
    local others = get_who_names()
    local others_qs = { }
    for _, other in ipairs(others) do
        table.insert(others_qs, string.format("other=%s", other))
    end
    return others_qs
end

function construct_querystring()
    local character = GetUnitName(_cnst.PLAYER)
    local realm = GetRealmName()
    local locale = GetLocale()
    local querystring = table.concat({ 
        string.format("realm=%s", realm),
        string.format("locale=%s", locale),
        string.format("self=%s", character),
        table.concat(get_others_querystrings(), "&"),
    }, "&")
    return _cnst.URL .. querystring
end

StaticPopupDialogs['WIFMS'] = {
    hasEditBox = true,
    button1 = 'Ok',
    hideOnEscape = true,
    whileDead = true,
    timeout = 0,
    text = 'URL',
    OnShow = function(self, data)
        self.editBox:SetText(construct_querystring())
    end,
}

function SlashCmdList.WIFMS(msg)
    SetWhoToUI(1)
    WIFMS_WAITING = true
    if #msg > 0 then
        who_message = msg
    else
        who_message = string.format('z-"%s"', GetZoneText())
    end
    SendWho(who_message)
end

function events:WHO_LIST_UPDATE(...)
    if WIFMS_WAITING then
        WIFMS_WAITING = false
        StaticPopup_Show('WIFMS')
    end
end

function events:ADDON_LOADED(...)
    if ... == 'wifms' then
        print('wifms loaded, usage:\n' ..
        '/wifms                  => Automatic, current zone\n' ..
        '/wifms [who string]     => A valid who string will be used\n')
    end
end

frame:SetScript('OnEvent', 
    function(self, event, ...)
        events[event](self, ...)
    end
)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end


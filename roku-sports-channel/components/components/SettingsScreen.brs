' ============================================================================
' SettingsScreen - App preferences
' ============================================================================

sub init()
    m.settingsGrid = m.top.FindNode("settingsGrid")

    m.settingsItems = [
        { label: "Video Quality", value: "Auto", key: "quality", options: ["Auto", "1080p", "720p", "480p"] },
        { label: "Preferred Sports", value: "All Sports", key: "sports" },
        { label: "Score Spoiler Protection", value: "Off", key: "spoilers", options: ["Off", "On"] },
        { label: "Live Notifications", value: "On", key: "notifications", options: ["On", "Off"] },
        { label: "Auto-Play Next", value: "On", key: "autoplay", options: ["On", "Off"] },
        { label: "Closed Captions", value: "Off", key: "captions", options: ["Off", "On", "Auto"] },
        { label: "Stream Source", value: "Default", key: "source" },
        { label: "Clear Watch History", value: "", key: "clearHistory" },
        { label: "Reset Favorites", value: "", key: "resetFavorites" },
        { label: "About", value: "v1.0.0", key: "about" }
    ]

    populateSettings()

    m.settingsGrid.ObserveField("itemSelected", "onSettingSelected")
end sub

function loadContent() as Void
    m.top.contentLoaded = true
end function

sub populateSettings()
    content = CreateObject("roSGNode", "ContentNode")

    for each item in m.settingsItems
        node = CreateObject("roSGNode", "ContentNode")
        node.AddFields({
            title: item.label,
            description: item.value,
            settingKey: item.key
        })

        ' Load saved value
        saved = RegistryRead("settings", item.key)
        if saved <> invalid
            node.description = saved
        end if

        content.AppendChild(node)
    end for

    m.settingsGrid.content = content
end sub

sub onSettingSelected(event as Object)
    idx = event.GetData()
    if idx < 0 OR idx >= m.settingsItems.Count() then return

    item = m.settingsItems[idx]

    if item.key = "clearHistory"
        RegistryDelete("history", "watchHistory")
        print "Settings: Watch history cleared"
    else if item.key = "resetFavorites"
        RegistryDelete("favorites", "teams")
        print "Settings: Favorites reset"
    else if item.DoesExist("options")
        ' Cycle through options
        currentVal = RegistryRead("settings", item.key)
        if currentVal = invalid
            currentVal = item.value
        end if

        options = item.options
        currentIdx = 0
        for i = 0 to options.Count() - 1
            if options[i] = currentVal
                currentIdx = i
                exit for
            end if
        end for

        nextIdx = (currentIdx + 1) MOD options.Count()
        newVal = options[nextIdx]
        RegistryWrite("settings", item.key, newVal)

        ' Update display
        node = m.settingsGrid.content.GetChild(idx)
        if node <> invalid
            node.description = newVal
        end if

        print "Settings: " + item.key + " = " + newVal
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return false
end function

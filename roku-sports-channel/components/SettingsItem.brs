' ============================================================================
' SettingsItem - Settings row rendering
' ============================================================================

sub init()
    m.settingLabel = m.top.FindNode("settingLabel")
    m.settingValue = m.top.FindNode("settingValue")
end sub

sub onContentChanged(event as Object)
    content = m.top.itemContent
    if content = invalid then return

    m.settingLabel.text = content.title
    m.settingValue.text = content.description
end sub

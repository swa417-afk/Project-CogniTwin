' ============================================================================
' NavTab - Individual tab button logic
' ============================================================================

sub init()
    m.tabBg = m.top.FindNode("tabBg")
    m.tabText = m.top.FindNode("tabText")
    m.activeIndicator = m.top.FindNode("activeIndicator")
end sub

sub onLabelChanged(event as Object)
    m.tabText.text = m.top.tabLabel
end sub

sub onStateChanged(event as Object)
    if m.top.isActive
        m.tabText.color = "#FFFFFF"
        m.activeIndicator.visible = true
    else if m.top.isFocused
        m.tabText.color = "#E10600"
        m.activeIndicator.visible = false
    else
        m.tabText.color = "#888899"
        m.activeIndicator.visible = false
    end if
end sub

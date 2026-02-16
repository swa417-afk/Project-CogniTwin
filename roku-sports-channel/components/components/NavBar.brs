' ============================================================================
' NavBar - Top navigation controller
' ============================================================================

sub init()
    m.tabGroup = m.top.FindNode("tabGroup")

    m.tabs = [
        m.top.FindNode("tab_home"),
        m.top.FindNode("tab_guide"),
        m.top.FindNode("tab_scores"),
        m.top.FindNode("tab_search"),
        m.top.FindNode("tab_favorites")
    ]

    m.tabNames = ["home", "guide", "scores", "search", "favorites"]
    m.focusedIndex = 0

    ' Set initial active state
    m.tabs[0].isActive = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if NOT press then return false

    if key = "right"
        if m.focusedIndex < m.tabs.Count() - 1
            m.focusedIndex = m.focusedIndex + 1
            updateFocus()
            return true
        end if
    else if key = "left"
        if m.focusedIndex > 0
            m.focusedIndex = m.focusedIndex - 1
            updateFocus()
            return true
        end if
    else if key = "OK"
        selectCurrentTab()
        return true
    else if key = "down"
        ' Let focus move down to content area
        return false
    end if

    return false
end function

sub updateFocus()
    for i = 0 to m.tabs.Count() - 1
        m.tabs[i].isFocused = (i = m.focusedIndex)
    end for
    m.top.focusedTab = m.focusedIndex
end sub

sub selectCurrentTab()
    ' Deactivate all tabs
    for each tab in m.tabs
        tab.isActive = false
    end for

    ' Activate selected
    m.tabs[m.focusedIndex].isActive = true
    m.top.selectedTab = m.tabNames[m.focusedIndex]
end sub

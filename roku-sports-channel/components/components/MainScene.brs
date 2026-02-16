' ============================================================================
' MainScene - Root scene controller
' Manages screen navigation, deep links, and global state
' ============================================================================

sub init()
    m.navBar = m.top.FindNode("navBar")
    m.screenContainer = m.top.FindNode("screenContainer")
    m.homeScreen = m.top.FindNode("homeScreen")
    m.liveGuide = m.top.FindNode("liveGuide")
    m.gameCenter = m.top.FindNode("gameCenter")
    m.searchScreen = m.top.FindNode("searchScreen")
    m.favoritesScreen = m.top.FindNode("favoritesScreen")
    m.settingsScreen = m.top.FindNode("settingsScreen")
    m.videoPlayer = m.top.FindNode("videoPlayer")
    m.loadingOverlay = m.top.FindNode("loadingOverlay")
    m.toast = m.top.FindNode("toast")

    ' Screen registry for navigation
    m.screens = {
        "home": m.homeScreen,
        "guide": m.liveGuide,
        "scores": m.gameCenter,
        "search": m.searchScreen,
        "favorites": m.favoritesScreen,
        "settings": m.settingsScreen
    }

    m.currentScreenName = "home"
    m.screenHistory = []

    ' Observe nav bar selection
    m.navBar.ObserveField("selectedTab", "onNavTabSelected")

    ' Observe video player events
    m.videoPlayer.ObserveField("playbackState", "onPlaybackStateChanged")
    m.videoPlayer.ObserveField("closeRequested", "onPlayerCloseRequested")

    ' Observe each screen's content selection for playback
    m.homeScreen.ObserveField("selectedContent", "onContentSelected")
    m.liveGuide.ObserveField("selectedContent", "onContentSelected")
    m.gameCenter.ObserveField("selectedContent", "onContentSelected")
    m.searchScreen.ObserveField("selectedContent", "onContentSelected")
    m.favoritesScreen.ObserveField("selectedContent", "onContentSelected")

    ' Initialize content feeds
    m.homeScreen.callFunc("loadContent")

    print "SportZone: MainScene initialized"
end sub

' ---- Navigation ----

sub onNavTabSelected(event as Object)
    tabName = event.GetData()
    navigateTo(tabName)
end sub

sub navigateTo(screenName as String)
    if screenName = m.currentScreenName then return

    ' Hide current screen
    currentScreen = m.screens[m.currentScreenName]
    if currentScreen <> invalid
        currentScreen.visible = false
    end if

    ' Show target screen
    targetScreen = m.screens[screenName]
    if targetScreen <> invalid
        targetScreen.visible = true
        targetScreen.SetFocus(true)

        ' Lazy-load content on first visit
        if NOT targetScreen.contentLoaded
            targetScreen.callFunc("loadContent")
        end if
    end if

    ' Track history for back navigation
    m.screenHistory.Push(m.currentScreenName)
    if m.screenHistory.Count() > 10
        m.screenHistory.Shift()
    end if

    m.currentScreenName = screenName
    m.top.currentScreen = screenName
    print "SportZone: Navigated to " + screenName
end sub

sub navigateBack()
    if m.screenHistory.Count() > 0
        previousScreen = m.screenHistory.Pop()
        ' Direct navigation without pushing to history again
        currentScreen = m.screens[m.currentScreenName]
        if currentScreen <> invalid
            currentScreen.visible = false
        end if

        targetScreen = m.screens[previousScreen]
        if targetScreen <> invalid
            targetScreen.visible = true
            targetScreen.SetFocus(true)
        end if

        m.currentScreenName = previousScreen
        m.top.currentScreen = previousScreen
    end if
end sub

' ---- Content Playback ----

sub onContentSelected(event as Object)
    contentItem = event.GetData()
    if contentItem <> invalid
        launchPlayer(contentItem)
    end if
end sub

sub launchPlayer(contentItem as Object)
    m.videoPlayer.content = contentItem
    m.videoPlayer.visible = true
    m.videoPlayer.SetFocus(true)
    m.videoPlayer.control = "play"
    print "SportZone: Launching player for " + contentItem.title
end sub

sub onPlaybackStateChanged(event as Object)
    state = event.GetData()
    if state = "error"
        showToast("Playback error. Please try again.")
    end if
end sub

sub onPlayerCloseRequested(event as Object)
    m.videoPlayer.control = "stop"
    m.videoPlayer.visible = false

    ' Return focus to current screen
    currentScreen = m.screens[m.currentScreenName]
    if currentScreen <> invalid
        currentScreen.SetFocus(true)
    end if
end sub

' ---- Deep Linking ----

sub onDeepLink(event as Object)
    link = event.GetData()
    if link = invalid then return

    contentId = link.contentId
    mediaType = link.mediaType

    print "SportZone: Deep link - contentId=" + contentId + " mediaType=" + mediaType

    if mediaType = "live"
        navigateTo("guide")
        m.liveGuide.callFunc("tuneToChannel", contentId)
    else if mediaType = "game"
        navigateTo("scores")
        m.gameCenter.callFunc("openGame", contentId)
    else
        navigateTo("home")
        m.homeScreen.callFunc("openContent", contentId)
    end if
end sub

' ---- UI Helpers ----

sub showLoading(message = "Loading..." as String)
    m.top.FindNode("loadingText").text = message
    m.loadingOverlay.visible = true
end sub

sub hideLoading()
    m.loadingOverlay.visible = false
end sub

sub showToast(message as String)
    m.toast.message = message
    m.toast.visible = true
end sub

' ---- Key Handling ----

function onKeyEvent(key as String, press as Boolean) as Boolean
    if NOT press then return false

    if key = "back"
        if m.videoPlayer.visible
            onPlayerCloseRequested(invalid)
            return true
        else if m.currentScreenName <> "home"
            navigateBack()
            return true
        end if
    else if key = "options"
        navigateTo("settings")
        return true
    end if

    return false
end function

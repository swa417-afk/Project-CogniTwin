' ============================================================================
' HomeScreen - FuboTV-style home with hero + scrolling content rows
' ============================================================================

sub init()
    m.heroBanner = m.top.FindNode("heroBanner")
    m.heroImage = m.top.FindNode("heroImage")
    m.heroTitle = m.top.FindNode("heroTitle")
    m.heroSubtitle = m.top.FindNode("heroSubtitle")
    m.heroLive = m.top.FindNode("heroLive")
    m.heroButton = m.top.FindNode("heroButton")
    m.heroBtnBg = m.top.FindNode("heroBtnBg")
    m.rowContainer = m.top.FindNode("rowContainer")

    m.rows = [
        m.top.FindNode("row_liveNow"),
        m.top.FindNode("row_trending"),
        m.top.FindNode("row_nfl"),
        m.top.FindNode("row_nba"),
        m.top.FindNode("row_soccer"),
        m.top.FindNode("row_mlb"),
        m.top.FindNode("row_nhl"),
        m.top.FindNode("row_combat"),
        m.top.FindNode("row_motor"),
        m.top.FindNode("row_recent")
    ]

    m.focusedRowIndex = -1  ' -1 = hero banner focused
    m.scrollY = 0

    ' Observe row selections
    for each row in m.rows
        row.ObserveField("itemSelected", "onRowItemSelected")
    end for
end sub

function loadContent() as Void
    print "HomeScreen: Loading content feeds..."

    ' Fetch featured content for hero banner
    m.feedTask = CreateObject("roSGNode", "ContentFeedTask")
    m.feedTask.ObserveField("response", "onFeedLoaded")
    m.feedTask.endpoint = "featured"
    m.feedTask.control = "run"

    ' Load each row's content
    for each row in m.rows
        row.callFunc("loadContent")
    end for

    m.top.contentLoaded = true
end function

sub onFeedLoaded(event as Object)
    response = event.GetData()
    if response <> invalid AND response.success = true
        featured = response.data
        if featured <> invalid AND featured.Count() > 0
            item = featured[0]
            m.heroTitle.text = item.title
            m.heroSubtitle.text = item.subtitle
            if item.isLive = true
                m.heroLive.text = "LIVE NOW"
                m.heroLive.color = "#E10600"
            else
                m.heroLive.text = GetRelativeTime(item.startTime)
                m.heroLive.color = "#AAAACC"
            end if
            if item.imageUrl <> invalid
                m.heroImage.uri = item.imageUrl
            end if
            m.heroContentItem = item
        end if
    end if
end sub

sub onRowItemSelected(event as Object)
    contentItem = event.GetData()
    if contentItem <> invalid
        m.top.selectedContent = contentItem
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if NOT press then return false

    if key = "down"
        if m.focusedRowIndex < m.rows.Count() - 1
            m.focusedRowIndex = m.focusedRowIndex + 1
            updateRowFocus()
            scrollToRow()
            return true
        end if
    else if key = "up"
        if m.focusedRowIndex >= 0
            m.focusedRowIndex = m.focusedRowIndex - 1
            updateRowFocus()
            scrollToRow()
            return true
        end if
    else if key = "OK"
        if m.focusedRowIndex = -1
            ' Hero banner selected - play featured content
            if m.heroContentItem <> invalid
                m.top.selectedContent = m.heroContentItem
            end if
            return true
        end if
    end if

    return false
end function

sub updateRowFocus()
    if m.focusedRowIndex = -1
        m.heroButton.SetFocus(true)
        m.heroBtnBg.color = "#FF2020"
    else
        m.heroBtnBg.color = "#E10600"
        m.rows[m.focusedRowIndex].SetFocus(true)
    end if
end sub

sub scrollToRow()
    ' Smooth scroll the row container to keep focused row visible
    if m.focusedRowIndex <= 0
        targetY = 0
    else
        targetY = -(m.focusedRowIndex * 290) + 100
    end if

    ' Animate scroll
    anim = m.top.FindNode("scrollAnim")
    if anim = invalid
        anim = CreateObject("roSGNode", "Animation")
        anim.id = "scrollAnim"
        anim.duration = 0.3
        anim.easeFunction = "outCubic"

        interp = CreateObject("roSGNode", "Vector2DFieldInterpolator")
        interp.fieldToInterp = m.rowContainer.id + ".translation"
        anim.AppendChild(interp)
        m.top.AppendChild(anim)
    end if

    interp = anim.GetChild(0)
    interp.keyValue = [[0, m.rowContainer.translation[1]], [0, 520 + targetY]]
    anim.control = "start"
end sub

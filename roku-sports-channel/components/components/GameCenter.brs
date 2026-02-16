' ============================================================================
' GameCenter - NBA League Pass-style scores and game details
' ============================================================================

sub init()
    m.dateSelector = m.top.FindNode("dateSelector")
    m.scoreTickerList = m.top.FindNode("scoreTickerList")
    m.gameGrid = m.top.FindNode("gameGrid")
    m.sectionLabel = m.top.FindNode("sectionLabel")
    m.gameDetailPanel = m.top.FindNode("gameDetailPanel")

    ' Detail panel fields
    m.detailLeague = m.top.FindNode("detailLeague")
    m.awayName = m.top.FindNode("awayName")
    m.awayScore = m.top.FindNode("awayScore")
    m.awayRecord = m.top.FindNode("awayRecord")
    m.awayLogo = m.top.FindNode("awayLogo")
    m.homeName = m.top.FindNode("homeName")
    m.homeScore = m.top.FindNode("homeScore")
    m.homeRecord = m.top.FindNode("homeRecord")
    m.homeLogo = m.top.FindNode("homeLogo")
    m.gameStatus = m.top.FindNode("gameStatus")
    m.gameVenue = m.top.FindNode("gameVenue")
    m.gameBroadcast = m.top.FindNode("gameBroadcast")

    m.games = []
    m.selectedDateIdx = 3  ' Today
    m.showingDetail = false
    m.selectedSport = "all"

    m.gameGrid.ObserveField("itemFocused", "onGameFocused")
    m.gameGrid.ObserveField("itemSelected", "onGameSelected")

    buildDateSelector()
end sub

sub buildDateSelector()
    now = CreateObject("roDateTime")
    nowSec = now.AsSeconds()

    ' Build 7 days: 3 past, today, 3 future
    for i = -3 to 3
        daySec = nowSec + (i * 86400)
        dt = CreateObject("roDateTime")
        dt.FromSeconds(daySec)

        tabNode = CreateObject("roSGNode", "Group")

        bg = CreateObject("roSGNode", "Rectangle")
        bg.width = 140
        bg.height = 60
        if i = 0
            bg.color = "#E10600"
        else
            bg.color = "#151530"
        end if
        tabNode.AppendChild(bg)

        dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        dayLabel = CreateObject("roSGNode", "Label")
        if i = 0
            dayLabel.text = "Today"
        else
            dayLabel.text = dayNames[dt.GetDayOfWeek()]
        end if
        dayLabel.font = "font:SmallBoldSystemFont"
        dayLabel.color = "#FFFFFF"
        dayLabel.translation = [30, 5]
        tabNode.AppendChild(dayLabel)

        dateLabel = CreateObject("roSGNode", "Label")
        dateLabel.text = monthNames[dt.GetMonth() - 1] + " " + dt.GetDayOfMonth().ToStr()
        dateLabel.font = "font:SmallestSystemFont"
        dateLabel.color = "#CCCCCC"
        dateLabel.translation = [30, 30]
        tabNode.AppendChild(dateLabel)

        m.dateSelector.AppendChild(tabNode)
    end for
end sub

function loadContent() as Void
    print "GameCenter: Loading scores and schedules..."

    task = CreateObject("roSGNode", "ContentFeedTask")
    task.ObserveField("response", "onGamesLoaded")
    task.endpoint = "scores"
    task.control = "run"

    m.top.contentLoaded = true
end function

sub onGamesLoaded(event as Object)
    response = event.GetData()
    if response <> invalid AND response.success = true AND response.data <> invalid
        m.games = response.data
        populateScoreTicker()
        populateGameGrid()
    end if
end sub

sub populateScoreTicker()
    content = CreateObject("roSGNode", "ContentNode")
    rowContent = CreateObject("roSGNode", "ContentNode")

    for each game in m.games
        node = CreateObject("roSGNode", "ContentNode")
        node.AddFields({
            title: game.awayTeam + " vs " + game.homeTeam,
            homeTeam: game.homeTeam,
            awayTeam: game.awayTeam,
            homeScore: game.homeScore,
            awayScore: game.awayScore,
            isLive: game.isLive,
            sport: game.sport,
            league: game.league,
            gameTime: game.startTime,
            quarter: game.period,
            streamUrl: game.streamUrl
        })
        rowContent.AppendChild(node)
    end for

    content.AppendChild(rowContent)
    m.scoreTickerList.content = content
end sub

sub populateGameGrid()
    content = CreateObject("roSGNode", "ContentNode")

    for each game in m.games
        if m.selectedSport = "all" OR LCase(game.sport) = m.selectedSport
            node = CreateObject("roSGNode", "ContentNode")
            node.AddFields({
                title: game.awayTeam + " @ " + game.homeTeam,
                description: game.venue,
                homeTeam: game.homeTeam,
                awayTeam: game.awayTeam,
                homeScore: game.homeScore,
                awayScore: game.awayScore,
                homeRecord: game.homeRecord,
                awayRecord: game.awayRecord,
                homeLogo: game.homeLogoUrl,
                awayLogo: game.awayLogoUrl,
                isLive: game.isLive,
                sport: game.sport,
                league: game.league,
                startTime: game.startTime,
                period: game.period,
                venue: game.venue,
                broadcast: game.broadcast,
                streamUrl: game.streamUrl,
                condensedUrl: game.condensedUrl,
                gameId: game.id
            })
            content.AppendChild(node)
        end if
    end for

    m.gameGrid.content = content
end sub

sub onGameFocused(event as Object)
    ' Show mini preview on focus - similar to League Pass hover
end sub

sub onGameSelected(event as Object)
    idx = event.GetData()
    content = m.gameGrid.content
    if content <> invalid AND idx >= 0
        node = content.GetChild(idx)
        if node <> invalid
            showGameDetail(node)
        end if
    end if
end sub

sub showGameDetail(gameNode as Object)
    m.detailLeague.text = UCase(gameNode.league)
    m.awayName.text = gameNode.awayTeam
    m.homeName.text = gameNode.homeTeam
    m.awayScore.text = gameNode.awayScore
    m.homeScore.text = gameNode.homeScore
    m.awayRecord.text = gameNode.awayRecord
    m.homeRecord.text = gameNode.homeRecord

    if gameNode.awayLogo <> invalid
        m.awayLogo.uri = gameNode.awayLogo
    end if
    if gameNode.homeLogo <> invalid
        m.homeLogo.uri = gameNode.homeLogo
    end if

    if gameNode.isLive
        m.gameStatus.text = "LIVE - " + gameNode.period
        m.gameStatus.color = "#E10600"
    else
        m.gameStatus.text = gameNode.startTime
        m.gameStatus.color = "#AAAACC"
    end if

    m.gameVenue.text = gameNode.venue
    m.gameBroadcast.text = gameNode.broadcast

    m.currentGameNode = gameNode

    ' Slide in animation
    slideAnim = CreateObject("roSGNode", "Animation")
    slideAnim.duration = 0.3
    slideAnim.easeFunction = "outCubic"

    interp = CreateObject("roSGNode", "Vector2DFieldInterpolator")
    interp.fieldToInterp = m.gameDetailPanel.id + ".translation"
    interp.keyValue = [[1920, 0], [1220, 0]]
    slideAnim.AppendChild(interp)

    m.gameDetailPanel.visible = true
    m.top.AppendChild(slideAnim)
    slideAnim.control = "start"

    m.showingDetail = true
end sub

sub hideGameDetail()
    m.gameDetailPanel.visible = false
    m.showingDetail = false
    m.gameGrid.SetFocus(true)
end sub

function openGame(gameId as String) as Void
    print "GameCenter: Opening game " + gameId
    for each game in m.games
        if game.id = gameId
            ' Auto-play this game
            m.top.selectedContent = {
                title: game.awayTeam + " @ " + game.homeTeam,
                streamUrl: game.streamUrl,
                isLive: game.isLive,
                sport: game.sport
            }
            exit for
        end if
    end for
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if NOT press then return false

    if key = "back" AND m.showingDetail
        hideGameDetail()
        return true
    else if key = "OK" AND m.showingDetail
        if m.currentGameNode <> invalid
            m.top.selectedContent = {
                title: m.currentGameNode.awayTeam + " @ " + m.currentGameNode.homeTeam,
                streamUrl: m.currentGameNode.streamUrl,
                isLive: m.currentGameNode.isLive,
                sport: m.currentGameNode.sport,
                hdPosterUrl: m.currentGameNode.awayLogo
            }
        end if
        return true
    end if

    return false
end function

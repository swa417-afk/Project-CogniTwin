' ============================================================================
' GameCard - Detailed game card rendering
' ============================================================================

sub init()
    m.gameBg = m.top.FindNode("gameBg")
    m.accentBar = m.top.FindNode("accentBar")
    m.leagueLabel = m.top.FindNode("leagueLabel")
    m.awayTeamLogo = m.top.FindNode("awayTeamLogo")
    m.awayTeamName = m.top.FindNode("awayTeamName")
    m.awayTeamRecord = m.top.FindNode("awayTeamRecord")
    m.awayTeamScore = m.top.FindNode("awayTeamScore")
    m.homeTeamLogo = m.top.FindNode("homeTeamLogo")
    m.homeTeamName = m.top.FindNode("homeTeamName")
    m.homeTeamRecord = m.top.FindNode("homeTeamRecord")
    m.homeTeamScore = m.top.FindNode("homeTeamScore")
    m.gameTimeLabel = m.top.FindNode("gameTimeLabel")
    m.broadcastLabel = m.top.FindNode("broadcastLabel")
    m.watchOverlay = m.top.FindNode("watchOverlay")
end sub

sub onContentChanged(event as Object)
    content = m.top.itemContent
    if content = invalid then return

    ' League
    if content.HasField("league") AND content.league <> invalid
        m.leagueLabel.text = UCase(content.league)
    end if

    ' Teams
    m.awayTeamName.text = content.awayTeam
    m.homeTeamName.text = content.homeTeam

    if content.HasField("awayRecord") AND content.awayRecord <> invalid
        m.awayTeamRecord.text = content.awayRecord
    end if
    if content.HasField("homeRecord") AND content.homeRecord <> invalid
        m.homeTeamRecord.text = content.homeRecord
    end if

    ' Logos
    if content.HasField("awayLogo") AND content.awayLogo <> invalid
        m.awayTeamLogo.uri = content.awayLogo
    end if
    if content.HasField("homeLogo") AND content.homeLogo <> invalid
        m.homeTeamLogo.uri = content.homeLogo
    end if

    ' Scores
    if content.HasField("awayScore") AND content.awayScore <> invalid
        m.awayTeamScore.text = content.awayScore.ToStr()
    end if
    if content.HasField("homeScore") AND content.homeScore <> invalid
        m.homeTeamScore.text = content.homeScore.ToStr()
    end if

    ' Sport accent color
    sport = ""
    if content.HasField("sport") AND content.sport <> invalid
        sport = content.sport
    end if
    m.accentBar.color = GetSportColor(sport)

    ' Status / time
    isLive = false
    if content.HasField("isLive")
        isLive = content.isLive
    end if

    if isLive
        period = ""
        if content.HasField("period") AND content.period <> invalid
            period = content.period
        end if
        m.gameTimeLabel.text = "LIVE - " + period
        m.gameTimeLabel.color = "#E10600"
    else if content.HasField("startTime") AND content.startTime <> invalid
        m.gameTimeLabel.text = content.startTime
        m.gameTimeLabel.color = "#AAAACC"
    end if

    if content.HasField("broadcast") AND content.broadcast <> invalid
        m.broadcastLabel.text = content.broadcast
    end if
end sub

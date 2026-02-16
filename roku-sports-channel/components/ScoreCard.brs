' ============================================================================
' ScoreCard - Compact score ticker
' ============================================================================

sub init()
    m.scoreBg = m.top.FindNode("scoreBg")
    m.leagueBadge = m.top.FindNode("leagueBadge")
    m.awayAbbr = m.top.FindNode("awayAbbr")
    m.awayScoreLabel = m.top.FindNode("awayScoreLabel")
    m.homeAbbr = m.top.FindNode("homeAbbr")
    m.homeScoreLabel = m.top.FindNode("homeScoreLabel")
    m.statusLabel = m.top.FindNode("statusLabel")
end sub

sub onContentChanged(event as Object)
    content = m.top.itemContent
    if content = invalid then return

    m.awayAbbr.text = content.awayTeam
    m.homeAbbr.text = content.homeTeam

    if content.HasField("awayScore") AND content.awayScore <> invalid
        m.awayScoreLabel.text = content.awayScore.ToStr()
    end if
    if content.HasField("homeScore") AND content.homeScore <> invalid
        m.homeScoreLabel.text = content.homeScore.ToStr()
    end if

    isLive = false
    if content.HasField("isLive")
        isLive = content.isLive
    end if

    if isLive
        m.statusLabel.text = content.quarter
        m.statusLabel.color = "#E10600"
        m.leagueBadge.color = "#E10600"
    else
        if content.HasField("gameTime")
            m.statusLabel.text = content.gameTime
        end if
        m.statusLabel.color = "#888899"
        m.leagueBadge.color = GetSportColor(content.sport)
    end if
end sub

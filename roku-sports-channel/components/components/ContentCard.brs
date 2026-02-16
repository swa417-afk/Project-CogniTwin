' ============================================================================
' ContentCard - Game/event card rendering
' ============================================================================

sub init()
    m.cardBg = m.top.FindNode("cardBg")
    m.thumbnail = m.top.FindNode("thumbnail")
    m.liveBadge = m.top.FindNode("liveBadge")
    m.sportBadge = m.top.FindNode("sportBadge")
    m.sportBadgeBg = m.top.FindNode("sportBadgeBg")
    m.sportLabel = m.top.FindNode("sportLabel")
    m.cardTitle = m.top.FindNode("cardTitle")
    m.cardSubtitle = m.top.FindNode("cardSubtitle")
    m.cardTime = m.top.FindNode("cardTime")
end sub

sub onContentChanged(event as Object)
    content = m.top.itemContent
    if content = invalid then return

    ' Set thumbnail
    if content.hdPosterUrl <> invalid AND content.hdPosterUrl <> ""
        m.thumbnail.uri = content.hdPosterUrl
    end if

    ' Title and subtitle
    m.cardTitle.text = content.title
    if content.description <> invalid
        m.cardSubtitle.text = content.description
    end if

    ' Live badge
    isLive = false
    if content.HasField("isLive")
        isLive = content.isLive
    end if
    m.liveBadge.visible = isLive

    ' Sport badge color
    sport = ""
    if content.HasField("sport") AND content.sport <> invalid
        sport = content.sport
    end if

    if sport <> ""
        m.sportBadgeBg.color = GetSportColor(sport)
        league = ""
        if content.HasField("league") AND content.league <> invalid
            league = UCase(content.league)
        end if
        m.sportLabel.text = league
        m.sportBadge.visible = true
    else
        m.sportBadge.visible = false
    end if

    ' Time display
    if isLive
        ' Show score if available
        if content.HasField("score") AND content.score <> invalid AND content.score <> ""
            m.cardTime.text = content.score
            m.cardTime.color = "#FFFFFF"
        else
            m.cardTime.text = "LIVE"
            m.cardTime.color = "#E10600"
        end if
    else if content.HasField("startTime") AND content.startTime <> invalid
        m.cardTime.text = GetRelativeTime(content.startTime)
        m.cardTime.color = "#AAAACC"
    end if
end sub

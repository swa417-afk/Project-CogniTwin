' ============================================================================
' ProgramCell - EPG grid cell
' ============================================================================

sub init()
    m.cellBg = m.top.FindNode("cellBg")
    m.programTitle = m.top.FindNode("programTitle")
    m.programTime = m.top.FindNode("programTime")
    m.liveTag = m.top.FindNode("liveTag")
end sub

sub onContentChanged(event as Object)
    content = m.top.itemContent
    if content = invalid then return

    m.programTitle.text = content.title

    if content.HasField("startTime") AND content.startTime <> invalid
        m.programTime.text = content.startTime
        if content.HasField("endTime") AND content.endTime <> invalid
            m.programTime.text = content.startTime + " - " + content.endTime
        end if
    end if

    isLive = false
    if content.HasField("isLive")
        isLive = content.isLive
    end if

    if isLive
        m.liveTag.text = "LIVE"
        m.cellBg.color = "#2A1A3A"

        ' Sport-specific accent
        if content.HasField("sport") AND content.sport <> invalid
            sportColor = GetSportColor(content.sport)
            ' Left accent bar effect
            m.cellBg.color = "#1E1040"
        end if
    else
        m.liveTag.text = ""
        m.cellBg.color = "#1C1C3A"
    end if
end sub

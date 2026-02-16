' ============================================================================
' ChannelLogo - EPG channel sidebar item
' ============================================================================

sub init()
    m.logoBg = m.top.FindNode("logoBg")
    m.channelIcon = m.top.FindNode("channelIcon")
    m.channelNumber = m.top.FindNode("channelNumber")
    m.channelName = m.top.FindNode("channelName")
end sub

sub onContentChanged(event as Object)
    content = m.top.itemContent
    if content = invalid then return

    if content.hdPosterUrl <> invalid
        m.channelIcon.uri = content.hdPosterUrl
    end if

    if content.HasField("channelNumber") AND content.channelNumber <> invalid
        m.channelNumber.text = "Ch " + content.channelNumber.ToStr()
    end if

    m.channelName.text = content.title
end sub

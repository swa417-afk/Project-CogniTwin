' TeamCard

sub init()
    m.teamBg = m.top.FindNode("teamBg")
    m.teamLogo = m.top.FindNode("teamLogo")
    m.teamName = m.top.FindNode("teamName")
end sub

sub onContentChanged(event as Object)
    content = m.top.itemContent
    if content = invalid then return

    m.teamName.text = content.title
    if content.hdPosterUrl <> invalid
        m.teamLogo.uri = content.hdPosterUrl
    end if
end sub

' SportBadge

sub init()
    m.badgeBg = m.top.FindNode("badgeBg")
    m.badgeLabel = m.top.FindNode("badgeLabel")
end sub

sub onNameChanged(event as Object)
    m.badgeLabel.text = m.top.sportName
end sub

sub onColorChanged(event as Object)
    m.badgeBg.color = m.top.sportColor
end sub

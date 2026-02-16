' FilterChip

sub init()
    m.chipBg = m.top.FindNode("chipBg")
    m.chipText = m.top.FindNode("chipText")
end sub

sub onLabelChanged(event as Object)
    m.chipText.text = m.top.chipLabel
    ' Auto-size background to text width
    textWidth = m.chipText.boundingRect().width
    m.chipBg.width = textWidth + 32
end sub

sub onStateChanged(event as Object)
    if m.top.isSelected
        m.chipBg.color = "#E10600"
        m.chipText.color = "#FFFFFF"
    else
        m.chipBg.color = "#2A2A4A"
        m.chipText.color = "#AAAACC"
    end if
end sub

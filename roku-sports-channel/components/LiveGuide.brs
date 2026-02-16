' ============================================================================
' LiveGuide - FuboTV-style EPG with program grid
' ============================================================================

sub init()
    m.channelList = m.top.FindNode("channelList")
    m.programList = m.top.FindNode("programList")
    m.timeSlots = m.top.FindNode("timeSlots")
    m.nowLine = m.top.FindNode("nowLine")
    m.miniPreview = m.top.FindNode("miniPreview")
    m.previewTitle = m.top.FindNode("previewTitle")
    m.previewInfo = m.top.FindNode("previewInfo")
    m.previewTime = m.top.FindNode("previewTime")
    m.previewThumb = m.top.FindNode("previewThumb")

    m.channels = []
    m.programs = []
    m.focusArea = "grid"  ' "filter", "grid", "preview"
    m.selectedChannelIdx = 0
    m.selectedTimeIdx = 0

    m.programList.ObserveField("itemFocused", "onProgramFocused")
    m.programList.ObserveField("itemSelected", "onProgramSelected")

    ' Build time header
    buildTimeSlots()
    updateNowIndicator()

    ' Timer for updating now line
    m.nowTimer = CreateObject("roSGNode", "Timer")
    m.nowTimer.duration = 60
    m.nowTimer.repeat = true
    m.nowTimer.ObserveField("fire", "updateNowIndicator")
    m.nowTimer.control = "start"
end sub

sub buildTimeSlots()
    now = CreateObject("roDateTime")
    ' Round down to nearest 30 min
    currentMin = now.GetMinutes()
    if currentMin >= 30
        startMin = 30
    else
        startMin = 0
    end if

    ' Create 12 half-hour time slots (6 hours of guide data)
    for i = 0 to 11
        slotNode = CreateObject("roSGNode", "Group")
        bg = CreateObject("roSGNode", "Rectangle")
        bg.width = 270
        bg.height = 50
        bg.color = "#151530"
        slotNode.AppendChild(bg)

        label = CreateObject("roSGNode", "Label")
        totalMin = startMin + (i * 30)
        slotHour = now.GetHours() + (totalMin \ 60)
        slotMin = totalMin MOD 60

        ' Format as 12-hour time
        displayHour = slotHour MOD 12
        if displayHour = 0 then displayHour = 12
        ampm = "AM"
        if slotHour >= 12 AND slotHour < 24 then ampm = "PM"

        label.text = displayHour.ToStr() + ":" + PadZero(slotMin) + " " + ampm
        label.font = "font:SmallestSystemFont"
        label.color = "#888899"
        label.translation = [10, 16]
        slotNode.AppendChild(label)

        m.timeSlots.AppendChild(slotNode)
    end for
end sub

sub updateNowIndicator()
    now = CreateObject("roDateTime")
    minutesPastHour = now.GetMinutes()
    ' Position the now line relative to the time header
    pixelsPerMinute = 270.0 / 30.0  ' each slot = 270px = 30min
    m.nowLine.translation = [pixelsPerMinute * minutesPastHour, 0]
end sub

function loadContent() as Void
    print "LiveGuide: Loading EPG data..."

    task = CreateObject("roSGNode", "ContentFeedTask")
    task.ObserveField("response", "onEPGLoaded")
    task.endpoint = "epg"
    task.control = "run"

    m.top.contentLoaded = true
end function

sub onEPGLoaded(event as Object)
    response = event.GetData()
    if response <> invalid AND response.success = true AND response.data <> invalid
        m.channels = response.data.channels
        m.programs = response.data.programs
        populateChannelList()
        populateProgramGrid()
    end if
end sub

sub populateChannelList()
    content = CreateObject("roSGNode", "ContentNode")
    for each channel in m.channels
        node = CreateObject("roSGNode", "ContentNode")
        node.AddFields({
            title: channel.name,
            hdPosterUrl: channel.logoUrl,
            channelNumber: channel.number,
            channelId: channel.id
        })
        content.AppendChild(node)
    end for
    m.channelList.content = content
end sub

sub populateProgramGrid()
    content = CreateObject("roSGNode", "ContentNode")
    for each program in m.programs
        node = CreateObject("roSGNode", "ContentNode")
        node.AddFields({
            title: program.title,
            description: program.description,
            startTime: program.startTime,
            endTime: program.endTime,
            isLive: program.isLive,
            sport: program.sport,
            streamUrl: program.streamUrl,
            hdPosterUrl: program.imageUrl,
            channelId: program.channelId
        })
        content.AppendChild(node)
    end for
    m.programList.content = content
end sub

sub onProgramFocused(event as Object)
    idx = event.GetData()
    content = m.programList.content
    if content <> invalid AND idx >= 0
        node = content.GetChild(idx)
        if node <> invalid
            m.previewTitle.text = node.title
            m.previewInfo.text = node.description
            if node.isLive
                m.previewTime.text = "LIVE NOW"
            else
                m.previewTime.text = node.startTime + " - " + node.endTime
            end if
            if node.hdPosterUrl <> invalid
                m.previewThumb.uri = node.hdPosterUrl
            end if
            m.miniPreview.visible = true
        end if
    end if
end sub

sub onProgramSelected(event as Object)
    idx = event.GetData()
    content = m.programList.content
    if content <> invalid AND idx >= 0
        node = content.GetChild(idx)
        if node <> invalid
            m.top.selectedContent = {
                title: node.title,
                description: node.description,
                streamUrl: node.streamUrl,
                isLive: node.isLive,
                sport: node.sport,
                hdPosterUrl: node.hdPosterUrl
            }
        end if
    end if
end sub

function tuneToChannel(channelId as String) as Void
    print "LiveGuide: Tuning to channel " + channelId
    ' Find channel in list and focus/play it
    for i = 0 to m.channels.Count() - 1
        if m.channels[i].id = channelId
            m.channelList.jumpToItem = i
            ' Find currently airing program on this channel
            for each program in m.programs
                if program.channelId = channelId AND program.isLive = true
                    m.top.selectedContent = {
                        title: program.title,
                        streamUrl: program.streamUrl,
                        isLive: true,
                        sport: program.sport
                    }
                    exit for
                end if
            end for
            exit for
        end if
    end for
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    if NOT press then return false

    if key = "OK"
        ' Select the currently focused program
        return false ' Let grid handle it
    else if key = "play"
        ' Quick play current selection
        return false
    end if

    return false
end function

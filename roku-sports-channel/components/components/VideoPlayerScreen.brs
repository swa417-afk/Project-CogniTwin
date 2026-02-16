' ============================================================================
' VideoPlayerScreen - Full-screen sports video player with HUD
' ============================================================================

sub init()
    m.videoNode = m.top.FindNode("videoNode")
    m.hudOverlay = m.top.FindNode("hudOverlay")
    m.controlsOverlay = m.top.FindNode("controlsOverlay")
    m.bufferingOverlay = m.top.FindNode("bufferingOverlay")
    m.hudMatchup = m.top.FindNode("hudMatchup")
    m.hudScore = m.top.FindNode("hudScore")
    m.hudPeriod = m.top.FindNode("hudPeriod")
    m.hudLeague = m.top.FindNode("hudLeague")
    m.hudLiveBadge = m.top.FindNode("hudLiveBadge")
    m.progressFill = m.top.FindNode("progressFill")
    m.progressKnob = m.top.FindNode("progressKnob")
    m.currentTime = m.top.FindNode("currentTime")
    m.totalTime = m.top.FindNode("totalTime")
    m.btnPlayPause = m.top.FindNode("btnPlayPause")
    m.qualityLabel = m.top.FindNode("qualityLabel")

    m.showingControls = false
    m.showingHud = false
    m.isLive = false

    ' Observe video state
    m.videoNode.ObserveField("state", "onVideoStateChanged")
    m.videoNode.ObserveField("position", "onPositionChanged")
    m.videoNode.ObserveField("duration", "onDurationChanged")
    m.videoNode.ObserveField("streamingSegment", "onSegmentChanged")

    ' Auto-hide controls timer
    m.hideTimer = CreateObject("roSGNode", "Timer")
    m.hideTimer.duration = 5
    m.hideTimer.ObserveField("fire", "hideControls")

    ' Score update timer (poll every 30s for live games)
    m.scoreTimer = CreateObject("roSGNode", "Timer")
    m.scoreTimer.duration = 30
    m.scoreTimer.repeat = true
    m.scoreTimer.ObserveField("fire", "updateLiveScore")
end sub

sub onContentChanged(event as Object)
    contentData = m.top.content
    if contentData = invalid then return

    ' Build video content node
    videoContent = CreateObject("roSGNode", "ContentNode")
    videoContent.title = contentData.title

    if contentData.streamUrl <> invalid
        videoContent.url = contentData.streamUrl
    end if

    ' Determine stream format
    streamFormat = "hls"
    if contentData.DoesExist("streamFormat") AND contentData.streamFormat <> invalid
        streamFormat = contentData.streamFormat
    end if
    videoContent.streamFormat = streamFormat

    m.videoNode.content = videoContent

    ' Set HUD info
    m.hudMatchup.text = contentData.title
    if contentData.DoesExist("league") AND contentData.league <> invalid
        m.hudLeague.text = UCase(contentData.league)
    end if

    m.isLive = false
    if contentData.DoesExist("isLive")
        m.isLive = contentData.isLive
    end if

    m.hudLiveBadge.visible = m.isLive
    if m.isLive
        m.scoreTimer.control = "start"
    end if

    print "VideoPlayer: Loading " + contentData.title
end sub

sub onControlChanged(event as Object)
    control = m.top.control
    if control = "play"
        m.videoNode.control = "play"
        m.videoNode.SetFocus(true)
    else if control = "stop"
        m.videoNode.control = "stop"
        m.scoreTimer.control = "stop"
    else if control = "pause"
        m.videoNode.control = "pause"
    else if control = "resume"
        m.videoNode.control = "resume"
    end if
end sub

sub onVideoStateChanged(event as Object)
    state = event.GetData()
    print "VideoPlayer: State = " + state

    if state = "buffering"
        m.bufferingOverlay.visible = true
    else
        m.bufferingOverlay.visible = false
    end if

    if state = "playing"
        m.btnPlayPause.text = "||"
        m.top.playbackState = "playing"
    else if state = "paused"
        m.btnPlayPause.text = ">"
        m.top.playbackState = "paused"
    else if state = "finished"
        m.top.playbackState = "finished"
        m.top.closeRequested = true
    else if state = "error"
        m.top.playbackState = "error"
        print "VideoPlayer: Playback error - " + m.videoNode.errorStr
    end if
end sub

sub onPositionChanged(event as Object)
    position = event.GetData()
    duration = m.videoNode.duration

    m.currentTime.text = FormatTime(Int(position))

    if duration > 0
        progress = position / duration
        barWidth = 1840 * progress
        m.progressFill.width = barWidth
        m.progressKnob.translation = [barWidth - 7, -5]
    end if
end sub

sub onDurationChanged(event as Object)
    duration = event.GetData()
    if m.isLive
        m.totalTime.text = "LIVE"
    else
        m.totalTime.text = FormatTime(Int(duration))
    end if
end sub

sub onSegmentChanged(event as Object)
    segment = event.GetData()
    if segment <> invalid AND segment.DoesExist("segBitrateBps")
        bitrate = segment.segBitrateBps / 1000
        if bitrate >= 4000
            m.qualityLabel.text = "4K"
        else if bitrate >= 2500
            m.qualityLabel.text = "HD"
        else if bitrate >= 1000
            m.qualityLabel.text = "SD"
        else
            m.qualityLabel.text = "LOW"
        end if
    end if
end sub

sub toggleControls()
    m.showingControls = NOT m.showingControls
    m.controlsOverlay.visible = m.showingControls

    if m.showingControls
        m.hideTimer.control = "start"
    else
        m.hideTimer.control = "stop"
    end if
end sub

sub toggleHud()
    m.showingHud = NOT m.showingHud
    m.hudOverlay.visible = m.showingHud
end sub

sub hideControls()
    m.showingControls = false
    m.controlsOverlay.visible = false
end sub

sub updateLiveScore()
    ' Fetch updated score for current game
    ' This would call the scores API endpoint
    print "VideoPlayer: Updating live score..."
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if NOT press then return false

    if key = "back"
        m.top.closeRequested = true
        return true
    else if key = "OK" OR key = "play"
        if m.videoNode.state = "playing"
            m.videoNode.control = "pause"
        else if m.videoNode.state = "paused"
            m.videoNode.control = "resume"
        end if
        toggleControls()
        return true
    else if key = "up"
        toggleHud()
        return true
    else if key = "down"
        toggleControls()
        return true
    else if key = "fastforward" OR key = "right"
        ' Skip forward 10 seconds
        newPos = m.videoNode.position + 10
        if newPos < m.videoNode.duration
            m.videoNode.seek = newPos
        end if
        return true
    else if key = "rewind" OR key = "left"
        ' Skip back 10 seconds
        newPos = m.videoNode.position - 10
        if newPos < 0 then newPos = 0
        m.videoNode.seek = newPos
        return true
    else if key = "options"
        ' Toggle stats HUD
        toggleHud()
        return true
    end if

    return false
end function

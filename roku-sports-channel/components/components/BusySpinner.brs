' BusySpinner - Simple animated loading indicator

sub init()
    m.spinnerDots = m.top.FindNode("spinnerDots")

    m.dotTimer = CreateObject("roSGNode", "Timer")
    m.dotTimer.duration = 0.5
    m.dotTimer.repeat = true
    m.dotTimer.ObserveField("fire", "animateDots")
    m.dotTimer.control = "start"

    m.dotState = 0
end sub

sub animateDots()
    m.dotState = (m.dotState + 1) MOD 4
    dots = ""
    for i = 0 to m.dotState
        dots = dots + "."
    end for
    m.spinnerDots.text = dots
end sub

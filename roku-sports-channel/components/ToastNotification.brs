' ToastNotification

sub init()
    m.toastBg = m.top.FindNode("toastBg")
    m.toastText = m.top.FindNode("toastText")

    m.hideTimer = CreateObject("roSGNode", "Timer")
    m.hideTimer.duration = 4
    m.hideTimer.ObserveField("fire", "hideToast")
end sub

sub onMessageChanged(event as Object)
    m.toastText.text = m.top.message
    m.top.visible = true
    m.hideTimer.control = "start"

    ' Slide in animation
    anim = CreateObject("roSGNode", "Animation")
    anim.duration = 0.3
    anim.easeFunction = "outCubic"

    interp = CreateObject("roSGNode", "FloatFieldInterpolator")
    interp.fieldToInterp = m.toastBg.id + ".opacity"
    interp.keyValue = [0.0, 0.95]
    anim.AppendChild(interp)
    m.top.AppendChild(anim)
    anim.control = "start"
end sub

sub hideToast()
    m.top.visible = false
end sub

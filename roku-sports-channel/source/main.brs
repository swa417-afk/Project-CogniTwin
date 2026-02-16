' ============================================================================
' SportZone - Main Entry Point
' Free sports streaming channel with FuboTV/League Pass style interface
' ============================================================================

sub Main(args as Dynamic)
    print "SportZone: Initializing channel..."

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    ' Create main scene
    scene = screen.CreateScene("MainScene")
    screen.Show()

    ' Handle deep linking from Roku Search
    if args <> invalid
        if args.contentId <> invalid AND args.contentId <> ""
            scene.deepLink = {
                contentId: args.contentId,
                mediaType: args.mediaType
            }
        end if
    end if

    ' Main event loop
    while true
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                print "SportZone: Channel closed."
                return
            end if
        end if
    end while
end sub

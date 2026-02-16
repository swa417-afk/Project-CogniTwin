' ============================================================================
' ContentFeedTask - Async data fetcher for all content APIs
'
' This task handles fetching from configurable content source APIs.
' Configure your API base URL in the channel settings or via the
' CONFIG_API_BASE constant below.
'
' Expected API contract:
'   GET /featured     -> array of featured events
'   GET /category     -> array of events filtered by sport
'   GET /epg          -> { channels: [], programs: [] }
'   GET /scores       -> array of games with live scores
'   GET /search?q=    -> array of search results
'   GET /trending     -> array of trending queries
'   GET /upcoming     -> array of upcoming games for team IDs
' ============================================================================

' ------------------------------------------------------------------
' CONFIGURATION: Set your content API base URL here.
' This should point to YOUR backend that serves legal content feeds.
' ------------------------------------------------------------------
function GetApiBaseUrl() as String
    ' Check registry for user-configured API
    saved = RegistryRead("settings", "apiBaseUrl")
    if saved <> invalid AND saved <> ""
        return saved
    end if

    ' Default: placeholder - replace with your actual content API
    return "https://your-sports-api.example.com/api/v1"
end function

sub init()
    m.top.functionName = "fetchContent"
end sub

sub fetchContent()
    endpoint = m.top.endpoint
    params = m.top.params

    baseUrl = GetApiBaseUrl()
    url = baseUrl + "/" + endpoint

    ' Build query string from params
    if params <> invalid AND params.Count() > 0
        url = BuildURL(url, params)
    end if

    print "ContentFeedTask: Fetching " + url

    result = HttpGet(url)

    if result.success
        m.top.response = { success: true, data: result.data }
    else
        print "ContentFeedTask: Error fetching " + endpoint + " - code " + result.code.ToStr()
        ' Return fallback/demo data for development
        m.top.response = { success: true, data: getDemoData(endpoint) }
    end if
end sub

' ============================================================================
' Demo/development data - returned when API is not configured
' Replace with real API integration for production
' ============================================================================

function getDemoData(endpoint as String) as Object
    if endpoint = "featured"
        return [
            {
                id: "feat_1",
                title: "Sunday Night Football",
                subtitle: "Cowboys vs Eagles - NFC East Showdown",
                imageUrl: "",
                streamUrl: "",
                isLive: true,
                startTime: "2026-02-15T20:00:00Z",
                sport: "nfl",
                league: "NFL"
            }
        ]
    else if endpoint = "category"
        return getDemoCategoryData()
    else if endpoint = "epg"
        return getDemoEPGData()
    else if endpoint = "scores"
        return getDemoScoresData()
    else if endpoint = "trending"
        return [
            { query: "NBA All-Star Game", count: 45200 },
            { query: "Super Bowl", count: 38100 },
            { query: "Champions League", count: 27400 },
            { query: "UFC Fight Night", count: 19800 },
            { query: "March Madness", count: 15600 }
        ]
    else if endpoint = "search"
        return []
    else if endpoint = "upcoming"
        return getDemoScoresData()
    end if

    return []
end function

function getDemoCategoryData() as Object
    return [
        {
            id: "cat_1",
            title: "Lakers vs Celtics",
            description: "NBA Regular Season",
            imageUrl: "",
            streamUrl: "",
            streamFormat: "hls",
            isLive: true,
            sport: "nba",
            league: "NBA",
            startTime: "2026-02-16T19:30:00Z",
            homeTeam: "BOS",
            awayTeam: "LAL",
            score: "LAL 87 - BOS 92"
        },
        {
            id: "cat_2",
            title: "Man City vs Liverpool",
            description: "Premier League - Matchday 25",
            imageUrl: "",
            streamUrl: "",
            streamFormat: "hls",
            isLive: false,
            sport: "soccer",
            league: "EPL",
            startTime: "2026-02-17T12:30:00Z",
            homeTeam: "MCI",
            awayTeam: "LIV",
            score: ""
        },
        {
            id: "cat_3",
            title: "UFC Fight Night",
            description: "Main Card - Heavyweight Bout",
            imageUrl: "",
            streamUrl: "",
            streamFormat: "hls",
            isLive: false,
            sport: "ufc",
            league: "UFC",
            startTime: "2026-02-16T22:00:00Z",
            homeTeam: "",
            awayTeam: "",
            score: ""
        },
        {
            id: "cat_4",
            title: "Yankees vs Red Sox",
            description: "Spring Training",
            imageUrl: "",
            streamUrl: "",
            streamFormat: "hls",
            isLive: false,
            sport: "mlb",
            league: "MLB",
            startTime: "2026-02-20T13:05:00Z",
            homeTeam: "BOS",
            awayTeam: "NYY",
            score: ""
        }
    ]
end function

function getDemoEPGData() as Object
    return {
        channels: [
            { id: "ch_1", name: "Sports Central", number: 101, logoUrl: "" },
            { id: "ch_2", name: "Game Network", number: 102, logoUrl: "" },
            { id: "ch_3", name: "Court TV Sports", number: 103, logoUrl: "" },
            { id: "ch_4", name: "Gridiron Channel", number: 104, logoUrl: "" },
            { id: "ch_5", name: "Soccer World", number: 105, logoUrl: "" },
            { id: "ch_6", name: "Ice Sports", number: 106, logoUrl: "" },
            { id: "ch_7", name: "Diamond Sports", number: 107, logoUrl: "" },
            { id: "ch_8", name: "Fight Network", number: 108, logoUrl: "" },
            { id: "ch_9", name: "Racing Channel", number: 109, logoUrl: "" },
            { id: "ch_10", name: "College Sports", number: 110, logoUrl: "" }
        ],
        programs: [
            { title: "NBA: Lakers vs Celtics", description: "Live basketball", startTime: "7:30 PM", endTime: "10:00 PM", isLive: true, sport: "nba", streamUrl: "", imageUrl: "", channelId: "ch_1" },
            { title: "NFL Replay: Cowboys vs Eagles", description: "Classic game replay", startTime: "8:00 PM", endTime: "11:00 PM", isLive: false, sport: "nfl", streamUrl: "", imageUrl: "", channelId: "ch_4" },
            { title: "EPL: Man City vs Liverpool", description: "Premier League", startTime: "12:30 PM", endTime: "2:30 PM", isLive: false, sport: "soccer", streamUrl: "", imageUrl: "", channelId: "ch_5" },
            { title: "NHL: Rangers vs Bruins", description: "Live hockey", startTime: "7:00 PM", endTime: "9:30 PM", isLive: true, sport: "nhl", streamUrl: "", imageUrl: "", channelId: "ch_6" },
            { title: "UFC Fight Night", description: "Main card", startTime: "10:00 PM", endTime: "1:00 AM", isLive: false, sport: "ufc", streamUrl: "", imageUrl: "", channelId: "ch_8" },
            { title: "Daytona 500 Qualifying", description: "NASCAR Sprint Cup", startTime: "2:00 PM", endTime: "5:00 PM", isLive: false, sport: "nascar", streamUrl: "", imageUrl: "", channelId: "ch_9" }
        ]
    }
end function

function getDemoScoresData() as Object
    return [
        {
            id: "game_1",
            homeTeam: "Boston Celtics",
            awayTeam: "LA Lakers",
            homeScore: 92,
            awayScore: 87,
            homeRecord: "38-15",
            awayRecord: "30-22",
            homeLogoUrl: "",
            awayLogoUrl: "",
            isLive: true,
            sport: "nba",
            league: "NBA",
            startTime: "7:30 PM ET",
            period: "3rd Qtr",
            venue: "TD Garden, Boston",
            broadcast: "Available on League Pass",
            streamUrl: "",
            condensedUrl: ""
        },
        {
            id: "game_2",
            homeTeam: "Philadelphia Eagles",
            awayTeam: "Dallas Cowboys",
            homeScore: 24,
            awayScore: 21,
            homeRecord: "12-5",
            awayRecord: "10-7",
            homeLogoUrl: "",
            awayLogoUrl: "",
            isLive: true,
            sport: "nfl",
            league: "NFL",
            startTime: "8:20 PM ET",
            period: "4th Qtr",
            venue: "Lincoln Financial Field",
            broadcast: "Sunday Night Football",
            streamUrl: "",
            condensedUrl: ""
        },
        {
            id: "game_3",
            homeTeam: "NY Rangers",
            awayTeam: "Boston Bruins",
            homeScore: 3,
            awayScore: 2,
            homeRecord: "33-18-4",
            awayRecord: "28-22-6",
            homeLogoUrl: "",
            awayLogoUrl: "",
            isLive: true,
            sport: "nhl",
            league: "NHL",
            startTime: "7:00 PM ET",
            period: "2nd Period",
            venue: "Madison Square Garden",
            broadcast: "Center Ice",
            streamUrl: "",
            condensedUrl: ""
        },
        {
            id: "game_4",
            homeTeam: "Manchester City",
            awayTeam: "Liverpool",
            homeScore: 0,
            awayScore: 0,
            homeRecord: "",
            awayRecord: "",
            homeLogoUrl: "",
            awayLogoUrl: "",
            isLive: false,
            sport: "soccer",
            league: "EPL",
            startTime: "Tomorrow 12:30 PM ET",
            period: "",
            venue: "Etihad Stadium",
            broadcast: "Peacock",
            streamUrl: "",
            condensedUrl: ""
        }
    ]
end function

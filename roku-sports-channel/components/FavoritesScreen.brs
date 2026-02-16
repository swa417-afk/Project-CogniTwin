' ============================================================================
' FavoritesScreen - My Teams management and personalized content
' ============================================================================

sub init()
    m.followedTeamsList = m.top.FindNode("followedTeamsList")
    m.upcomingGrid = m.top.FindNode("upcomingGrid")

    m.favoriteTeams = []

    ' Load saved favorites from registry
    loadFavorites()

    m.upcomingGrid.ObserveField("itemSelected", "onGameSelected")
end sub

function loadContent() as Void
    m.top.contentLoaded = true

    if m.favoriteTeams.Count() > 0
        loadUpcomingGames()
    end if
    populateFollowedTeams()
end function

sub loadFavorites()
    saved = RegistryRead("favorites", "teams")
    if saved <> invalid
        parsed = ParseJson(saved)
        if parsed <> invalid
            m.favoriteTeams = parsed
        end if
    end if
end sub

sub saveFavorites()
    json = FormatJson(m.favoriteTeams)
    RegistryWrite("favorites", "teams", json)
end sub

sub addFavoriteTeam(team as Object)
    ' Check if already in favorites
    for each fav in m.favoriteTeams
        if fav.id = team.id then return
    end for

    m.favoriteTeams.Push(team)
    saveFavorites()
    populateFollowedTeams()
    loadUpcomingGames()
end sub

sub removeFavoriteTeam(teamId as String)
    newFavs = []
    for each fav in m.favoriteTeams
        if fav.id <> teamId
            newFavs.Push(fav)
        end if
    end for
    m.favoriteTeams = newFavs
    saveFavorites()
    populateFollowedTeams()
end sub

sub populateFollowedTeams()
    content = CreateObject("roSGNode", "ContentNode")
    rowContent = CreateObject("roSGNode", "ContentNode")

    for each team in m.favoriteTeams
        node = CreateObject("roSGNode", "ContentNode")
        node.AddFields({
            title: team.name,
            hdPosterUrl: team.logoUrl,
            teamId: team.id,
            sport: team.sport,
            league: team.league
        })
        rowContent.AppendChild(node)
    end for

    content.AppendChild(rowContent)
    m.followedTeamsList.content = content
end sub

sub loadUpcomingGames()
    teamIds = []
    for each team in m.favoriteTeams
        teamIds.Push(team.id)
    end for

    task = CreateObject("roSGNode", "ContentFeedTask")
    task.ObserveField("response", "onUpcomingLoaded")
    task.endpoint = "upcoming"
    task.params = { teamIds: teamIds }
    task.control = "run"
end sub

sub onUpcomingLoaded(event as Object)
    response = event.GetData()
    if response <> invalid AND response.success = true AND response.data <> invalid
        content = CreateObject("roSGNode", "ContentNode")
        for each game in response.data
            node = CreateObject("roSGNode", "ContentNode")
            node.AddFields({
                title: game.awayTeam + " @ " + game.homeTeam,
                homeTeam: game.homeTeam,
                awayTeam: game.awayTeam,
                homeScore: game.homeScore,
                awayScore: game.awayScore,
                isLive: game.isLive,
                sport: game.sport,
                league: game.league,
                startTime: game.startTime,
                streamUrl: game.streamUrl
            })
            content.AppendChild(node)
        end for
        m.upcomingGrid.content = content
    end if
end sub

sub onGameSelected(event as Object)
    idx = event.GetData()
    content = m.upcomingGrid.content
    if content <> invalid AND idx >= 0
        node = content.GetChild(idx)
        if node <> invalid
            m.top.selectedContent = {
                title: node.title,
                streamUrl: node.streamUrl,
                isLive: node.isLive,
                sport: node.sport
            }
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return false
end function

' ============================================================================
' SearchScreen - Search for games, teams, and sports
' ============================================================================

sub init()
    m.searchKeyboard = m.top.FindNode("searchKeyboard")
    m.resultsGrid = m.top.FindNode("resultsGrid")
    m.resultsLabel = m.top.FindNode("resultsLabel")
    m.trendingList = m.top.FindNode("trendingList")

    m.searchTimer = CreateObject("roSGNode", "Timer")
    m.searchTimer.duration = 0.5
    m.searchTimer.ObserveField("fire", "executeSearch")

    m.searchKeyboard.ObserveField("text", "onSearchTextChanged")
    m.resultsGrid.ObserveField("itemSelected", "onResultSelected")
end sub

function loadContent() as Void
    m.top.contentLoaded = true
    loadTrending()
end function

sub loadTrending()
    task = CreateObject("roSGNode", "ContentFeedTask")
    task.ObserveField("response", "onTrendingLoaded")
    task.endpoint = "trending"
    task.control = "run"
end sub

sub onTrendingLoaded(event as Object)
    response = event.GetData()
    if response <> invalid AND response.success = true AND response.data <> invalid
        for each item in response.data
            trendItem = CreateObject("roSGNode", "Group")
            bg = CreateObject("roSGNode", "Rectangle")
            bg.width = 500
            bg.height = 40
            bg.color = "#1C1C3A"
            bg.cornerRadius = 4
            trendItem.AppendChild(bg)

            label = CreateObject("roSGNode", "Label")
            label.text = item.query
            label.font = "font:SmallSystemFont"
            label.color = "#FFFFFF"
            label.translation = [12, 8]
            trendItem.AppendChild(label)

            countLabel = CreateObject("roSGNode", "Label")
            countLabel.text = item.count.ToStr() + " watching"
            countLabel.font = "font:SmallestSystemFont"
            countLabel.color = "#E10600"
            countLabel.translation = [350, 10]
            trendItem.AppendChild(countLabel)

            m.trendingList.AppendChild(trendItem)
        end for
    end if
end sub

sub onSearchTextChanged(event as Object)
    m.searchTimer.control = "stop"
    m.searchTimer.control = "start"
end sub

sub executeSearch()
    query = m.searchKeyboard.text
    if Len(query) < 2 then return

    print "SearchScreen: Searching for '" + query + "'"

    task = CreateObject("roSGNode", "ContentFeedTask")
    task.ObserveField("response", "onSearchResults")
    task.endpoint = "search"
    task.params = { q: query }
    task.control = "run"
end sub

sub onSearchResults(event as Object)
    response = event.GetData()
    if response <> invalid AND response.success = true AND response.data <> invalid
        results = response.data
        m.resultsLabel.text = results.Count().ToStr() + " Results"

        content = CreateObject("roSGNode", "ContentNode")
        for each item in results
            node = CreateObject("roSGNode", "ContentNode")
            node.AddFields({
                title: item.title,
                description: item.description,
                hdPosterUrl: item.imageUrl,
                streamUrl: item.streamUrl,
                isLive: item.isLive,
                sport: item.sport,
                league: item.league,
                contentId: item.id
            })
            content.AppendChild(node)
        end for
        m.resultsGrid.content = content
    else
        m.resultsLabel.text = "No results found"
    end if
end sub

sub onResultSelected(event as Object)
    idx = event.GetData()
    content = m.resultsGrid.content
    if content <> invalid AND idx >= 0
        node = content.GetChild(idx)
        if node <> invalid
            m.top.selectedContent = {
                title: node.title,
                streamUrl: node.streamUrl,
                isLive: node.isLive,
                sport: node.sport,
                contentId: node.contentId,
                hdPosterUrl: node.hdPosterUrl
            }
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return false
end function

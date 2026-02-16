' ============================================================================
' ContentRow - Horizontal content row logic
' ============================================================================

sub init()
    m.titleLabel = m.top.FindNode("titleLabel")
    m.seeAllLabel = m.top.FindNode("seeAllLabel")
    m.rowList = m.top.FindNode("rowList")

    m.rowList.ObserveField("rowItemSelected", "onItemSelected")
end sub

sub onTitleChanged(event as Object)
    m.titleLabel.text = m.top.rowTitle
    ' Position "See All" label to the right of title
    titleWidth = m.titleLabel.boundingRect().width
    m.seeAllLabel.translation = [titleWidth + 30, 5]
end sub

function loadContent() as Void
    task = CreateObject("roSGNode", "ContentFeedTask")
    task.ObserveField("response", "onFeedResponse")
    task.endpoint = "category"
    task.params = { sport: m.top.sportFilter }
    task.control = "run"
    m.top.contentLoaded = true
end function

sub onFeedResponse(event as Object)
    response = event.GetData()
    if response <> invalid AND response.success = true AND response.data <> invalid
        populateRow(response.data)
    end if
end sub

sub onContentChanged(event as Object)
    items = m.top.contentList
    if items <> invalid
        populateRow(items)
    end if
end sub

sub populateRow(items as Object)
    content = CreateObject("roSGNode", "ContentNode")
    rowContent = CreateObject("roSGNode", "ContentNode")

    for each item in items
        cardNode = CreateObject("roSGNode", "ContentNode")
        cardNode.AddFields({
            title: item.title,
            description: item.description,
            hdPosterUrl: item.imageUrl,
            streamUrl: item.streamUrl,
            streamFormat: item.streamFormat,
            isLive: item.isLive,
            sport: item.sport,
            league: item.league,
            startTime: item.startTime,
            homeTeam: item.homeTeam,
            awayTeam: item.awayTeam,
            score: item.score,
            contentId: item.id
        })
        rowContent.AppendChild(cardNode)
    end for

    content.AppendChild(rowContent)
    m.rowList.content = content
end sub

sub onItemSelected(event as Object)
    indices = event.GetData()
    rowContent = m.rowList.content.GetChild(0)
    if rowContent <> invalid
        selectedNode = rowContent.GetChild(indices[1])
        if selectedNode <> invalid
            m.top.itemSelected = {
                title: selectedNode.title,
                description: selectedNode.description,
                streamUrl: selectedNode.streamUrl,
                streamFormat: selectedNode.streamFormat,
                hdPosterUrl: selectedNode.hdPosterUrl,
                isLive: selectedNode.isLive,
                sport: selectedNode.sport,
                league: selectedNode.league,
                contentId: selectedNode.contentId
            }
        end if
    end if
end sub

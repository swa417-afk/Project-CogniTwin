' ============================================================================
' SportZone - Utility Functions
' ============================================================================

' Format seconds into HH:MM:SS display string
function FormatTime(totalSeconds as Integer) as String
    hours = totalSeconds \ 3600
    minutes = (totalSeconds MOD 3600) \ 60
    seconds = totalSeconds MOD 60

    if hours > 0
        return hours.ToStr() + ":" + PadZero(minutes) + ":" + PadZero(seconds)
    else
        return minutes.ToStr() + ":" + PadZero(seconds)
    end if
end function

function PadZero(n as Integer) as String
    if n < 10
        return "0" + n.ToStr()
    end if
    return n.ToStr()
end function

' Parse ISO 8601 date string to roDateTime
function ParseISODate(dateStr as String) as Object
    dt = CreateObject("roDateTime")
    dt.FromISO8601String(dateStr)
    return dt
end function

' Get relative time description (e.g., "2 hours ago", "Starting in 30 min")
function GetRelativeTime(isoDate as String) as String
    target = ParseISODate(isoDate)
    now = CreateObject("roDateTime")

    diffSeconds = target.AsSeconds() - now.AsSeconds()

    if diffSeconds < 0
        ' In the past
        absDiff = Abs(diffSeconds)
        if absDiff < 60
            return "Just now"
        else if absDiff < 3600
            mins = absDiff \ 60
            return mins.ToStr() + "m ago"
        else if absDiff < 86400
            hours = absDiff \ 3600
            return hours.ToStr() + "h ago"
        else
            days = absDiff \ 86400
            return days.ToStr() + "d ago"
        end if
    else
        ' In the future
        if diffSeconds < 60
            return "Starting now"
        else if diffSeconds < 3600
            mins = diffSeconds \ 60
            return "In " + mins.ToStr() + "m"
        else if diffSeconds < 86400
            hours = diffSeconds \ 3600
            return "In " + hours.ToStr() + "h"
        else
            days = diffSeconds \ 86400
            return "In " + days.ToStr() + "d"
        end if
    end if
end function

' Truncate string with ellipsis
function Truncate(text as String, maxLen as Integer) as String
    if Len(text) <= maxLen
        return text
    end if
    return Left(text, maxLen - 3) + "..."
end function

' Create a color integer from hex string (e.g., "#FF0000" -> color int)
function HexToColor(hexStr as String) as Integer
    cleaned = hexStr
    if Left(cleaned, 1) = "#"
        cleaned = Mid(cleaned, 2)
    end if
    if Len(cleaned) = 6
        cleaned = cleaned + "FF"  ' Add full alpha
    end if
    return Val("&h" + cleaned)
end function

' Get sport category color theme
function GetSportColor(sport as String) as String
    sportColors = {
        "nfl": "#013369",
        "nba": "#1D428A",
        "mlb": "#002D72",
        "nhl": "#000000",
        "soccer": "#2E7D32",
        "mls": "#E42320",
        "epl": "#3D195B",
        "ufc": "#D20A0A",
        "boxing": "#8B0000",
        "tennis": "#4E8542",
        "golf": "#006747",
        "nascar": "#FFC107",
        "f1": "#E10600",
        "college": "#FF6F00",
        "olympics": "#0085C7",
        "cricket": "#1B5E20",
        "rugby": "#2E7D32"
    }

    lowerSport = LCase(sport)
    if sportColors.DoesExist(lowerSport)
        return sportColors[lowerSport]
    end if
    return "#1a1a2e"
end function

' Build URL with query parameters
function BuildURL(baseUrl as String, params as Object) as String
    if params = invalid OR params.Count() = 0
        return baseUrl
    end if

    url = baseUrl + "?"
    first = true
    for each key in params
        if NOT first
            url = url + "&"
        end if
        value = params[key]
        if value <> invalid
            url = url + key + "=" + value.EncodeUri()
        end if
        first = false
    end for
    return url
end function

' Registry helpers for persistent storage
function RegistryRead(section as String, key as String) as Dynamic
    reg = CreateObject("roRegistrySection", section)
    if reg.Exists(key)
        return reg.Read(key)
    end if
    return invalid
end function

sub RegistryWrite(section as String, key as String, value as String)
    reg = CreateObject("roRegistrySection", section)
    reg.Write(key, value)
    reg.Flush()
end sub

sub RegistryDelete(section as String, key as String)
    reg = CreateObject("roRegistrySection", section)
    reg.Delete(key)
    reg.Flush()
end sub

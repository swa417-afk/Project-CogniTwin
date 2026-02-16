' ============================================================================
' SportZone - Network Manager
' Handles all HTTP requests, caching, and API communication
' ============================================================================

' Make a GET request and return parsed JSON
function HttpGet(url as String, headers = invalid as Object) as Object
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.EnableEncodings(true)
    request.RetainBodyOnError(true)

    if headers <> invalid
        for each key in headers
            request.AddHeader(key, headers[key])
        end for
    end if

    request.AddHeader("Accept", "application/json")
    request.AddHeader("User-Agent", "SportZone/1.0 Roku")

    if request.AsyncGetToString()
        msg = wait(10000, port)
        if type(msg) = "roUrlEvent"
            responseCode = msg.GetResponseCode()
            body = msg.GetString()

            if responseCode >= 200 AND responseCode < 300
                json = ParseJson(body)
                if json <> invalid
                    return { success: true, data: json, code: responseCode }
                else
                    return { success: true, data: body, code: responseCode }
                end if
            else
                print "SportZone HTTP Error: " + responseCode.ToStr() + " - " + url
                return { success: false, data: invalid, code: responseCode, error: body }
            end if
        else
            print "SportZone: Request timeout - " + url
            return { success: false, data: invalid, code: -1, error: "Request timeout" }
        end if
    end if

    return { success: false, data: invalid, code: -1, error: "Failed to send request" }
end function

' Make a POST request with JSON body
function HttpPost(url as String, body as Object, headers = invalid as Object) as Object
    request = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    request.SetMessagePort(port)
    request.SetUrl(url)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.RetainBodyOnError(true)
    request.SetRequest("POST")

    if headers <> invalid
        for each key in headers
            request.AddHeader(key, headers[key])
        end for
    end if

    request.AddHeader("Content-Type", "application/json")
    request.AddHeader("Accept", "application/json")

    jsonBody = FormatJson(body)

    if request.AsyncPostFromString(jsonBody)
        msg = wait(10000, port)
        if type(msg) = "roUrlEvent"
            responseCode = msg.GetResponseCode()
            responseBody = msg.GetString()

            if responseCode >= 200 AND responseCode < 300
                json = ParseJson(responseBody)
                return { success: true, data: json, code: responseCode }
            else
                return { success: false, data: invalid, code: responseCode, error: responseBody }
            end if
        end if
    end if

    return { success: false, data: invalid, code: -1, error: "Failed to send request" }
end function

require "socket.http"
require "socket.url"

function socket.http.mkpost(fields)
    buf = {}
    
    for field,value in pairs(fields) do
        buf[#buf+1] = string.format("%s=%s"
            , socket.url.escape(tostring(field))
            , socket.url.escape(tostring(value)))
    end
    
    return table.concat(buf, "&")
end

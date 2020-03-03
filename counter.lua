-- example dynamic request script which demonstrates changing
-- the request path and a header for each request
-------------------------------------------------------------
-- NOTE: each wrk thread has an independent Lua scripting
-- context and thus there will be one counter per thread

counter = 0

request = function()
   path = "/test"
   req_body   = counter
   counter = counter + 1
   return wrk.format("POST", path, nil,req_body)
end

openssl = require "openssl"
base64 = require "base64"
JSON = require("JSON")
inspect = require("inspect")
local config = require "config"
index = 1
arr = {}
Minter1PrivateKey = nil

local t_counter = 1
local threads = {}

function setup(thread)
   thread:set("id", t_counter)
   table.insert(threads, thread)
   t_counter = t_counter + 1
end

function init(args)
  Minter1PrivateKey = openssl.pkey.read(config.key_data.Minter1PrivateKey, true)

  local file = io.open("res/create_wallet/responseCreateWalllet_" .. id ..  ".txt", "r");
  for line in file:lines() do
     table.insert (arr, line);
  end
  -- for i, v in ipairs(arr) do
  --   --local myText = display.newText( v, 0, 0, native.systemFont, 35 )
  --   print(v)
  -- end

end

request = function()
  -- res_file = file.open
  nonce = openssl.random(32)
  node_id = config.key_data.Minter1NodeID
  ts = os.time()

  data = JSON:decode(arr[index])
  params = {
    to_wallet_id = data.data.wallet_id,
    from_bank_code = "001",
    from_acct_id = "0123456789",
    amount = "10000.00",
    req_datetime = os.date("%Y-%m-%dT%H:%M:%S.000Z", os.time())
  }
  sendObj = JSON:encode(params) 
  newMsg = node_id .. sendObj .. nonce .. ts
  --print(newMsg)
  newSignature = Minter1PrivateKey.sign(Minter1PrivateKey, newMsg, "sha256")
  --print(signatureStr)
  newb64Signature = base64.encode(newSignature)
  
  -- print(JSON:encode(params))
  path = "/api/lookup_for_transfer_in"
  -- path="/test"
  param = {
    node_id = node_id,
    signature = newb64Signature,
    nonce = base64.encode(nonce),
    timestamp = ts,
    params = params
  }
  req_body = JSON:encode(param)
  print(req_body)
  -- print(index)
  -- print(arr[index])
  -- data = JSON:decode(arr[index])
  -- print(data)
  -- print(data.data.wallet_id)

  -- print(index)
  -- ts = os.date()
  -- print(os.date("%Y-%m-%dT%H:%M:%S.000Z",d))

  index = index + 1
  return wrk.format("POST", path, nil, req_body)
end

function response(status, headers, body)
  file = io.open("res/look_up/responseLookUpTranferIn_" .. id ..  ".txt", "a+")
  file:write(body,"\n")
  file:flush()
  file:close()

  if index == table.getn(arr) + 1 then
     wrk.thread:stop()
  end

  -- print(body)
  -- counter = counter + 1
end

function done(summary, latency, requests)
 print("DONE")
end
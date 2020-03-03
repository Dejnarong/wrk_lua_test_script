openssl = require "openssl"
base64 = require "base64"
JSON = require("JSON")
inspect = require("inspect")
local config = require "config"

pkey = config.key_data.provider1Wallet1Privkey
provider1PrivateKeyRaw = config.key_data.Provider1PrivateKey
provider1PrivateKey = nil

b64Signature = nil
jsonObj = {}
sendObj = {}

local t_counter = 1
local threads = {}

function setup(thread)
   thread:set("id", t_counter)
   table.insert(threads, thread)
   t_counter = t_counter + 1
end

function init(args)
  privKey = openssl.pkey.read(pkey, true)
  provider1PrivateKey = openssl.pkey.read(provider1PrivateKeyRaw, true)
  message = config.key_data.provider1Wallet1Pubkey
  signatureStr = privKey.sign(privKey, message, "sha256")
  --print(signatureStr)
  b64Signature = base64.encode(signatureStr)
  --print(b64Signature)
  jsonObj = {
    wallet_public_key = message,
		wallet_public_key_signature = b64Signature
  }
  sendObj = JSON:encode(jsonObj)
  --print(id)
  --print(sendObj)
end

request = function()
  nonce = openssl.random(32)
  node_id = "provider1"
  ts = os.time()

  newMsg = node_id .. sendObj .. nonce .. ts
  --print(newMsg)
  newSignature = provider1PrivateKey.sign(provider1PrivateKey, newMsg, "sha256")
  --print(signatureStr)
  newb64Signature = base64.encode(newSignature)

  path = "/api/create_wallet"
  param = {
    node_id = node_id,
    signature = newb64Signature,
    nonce = base64.encode(nonce),
    timestamp = ts,
    params = jsonObj
  }
  req_body = JSON:encode(param)
  --print(req_body)
  return wrk.format("POST", path, nil,req_body)
end

function response(status, headers, body)
  -- print(body)
  file = io.open("res/create_wallet/responseCreateWalllet_" .. id .. ".txt", "a+")
  file:write(body,"\n")
  file:flush()
  file:close()
end



-- account = config.objData
-- json_text = JSON:encode(account)

-- print(json_text)
-- print(config.key_data.privateKey)
-- node_id: nodeId,
-- signature,
-- nonce,
-- timestamp: ts,
-- params,

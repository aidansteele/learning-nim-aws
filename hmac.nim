import md5
import strutils
import strhelpers

proc SHA256(d: cstring, n: culong, md: cstring = nil): cstring {.cdecl, dynlib: "/usr/local/Cellar/openssl/1.0.2g/lib/libcrypto.dylib", importc.}
proc sha256*(s: string): string = 
  # todo: there's gotta be a better way to turn a byte buffer into a string
  let res: cstring = SHA256(s, culong(len(s)))
  result = newStringOfCap(32)
  for i in 0..31:
    add(result, res[i])

proc hmac*(key: string, data: string, hash_fn: proc(inp: string): string, block_size: int = 64): string =
  var k = key
  
  if len(k) > block_size:
    k = hash_fn(k)
  while len(k) < block_size:
    k = k & "\x00"
  
  const opad = 0x5c
  const ipad = 0x36
  var o_key_pad = newString(block_size) #seq[uint8] = @[]
  var i_key_pad = newString(block_size)
  
  for i in 0..block_size-1:
    o_key_pad[i] = char(k[i].ord xor opad)
    i_key_pad[i] = char(k[i].ord xor ipad)
    
  let inner = hash_fn(i_key_pad & data)
  result = hash_fn(o_key_pad & inner)

proc hmac_sha256*(key, data: string): string =
  result = hmac(key, data, proc(inp: string): string = sha256(inp))

proc md5_to_raw_str(md5: MD5Digest): string =
  result = ""
  for d in md5:
    add(result, chr(d))

proc hmac_md5*(key, data: string): string =
  result = hmac(key, data, proc(inp: string): string = md5_to_raw_str(toMD5(inp)))

when defined(testing): 
  import unittest
  import strhelpers

  let body = "The quick brown fox jumps over the lazy dog"
  check:
    hexify(hmac_sha256("key", body)) == "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"
    hexify(hmac_md5("key", body)) == "80070713463e7749b90c2dc24911e275"
    
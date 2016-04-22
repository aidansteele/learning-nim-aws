import awscredentials
import awsrequest
import uri
import strtabs
import strhelpers
import awshttp
import hmac

var payload = ""
var payloadHash = sha256(payload) 

var req = AwsRequest[StringTableRef](
  httpMethod: "GET", 
  uri: parseUri("https://s3.amazonaws.com/"), 
  headers: newStringTable({
    "x-amz-content-sha256": hexify(payloadHash),
  }), 
  payloadHash: payloadHash
)

let creds = initAwsCredentialsFromEnv()
let resp = request(req, creds)
echo resp

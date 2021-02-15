import json,os,boto3,uuid
from botocore.vendored import requests

def lambda_handler(event, context):
    # TODO implement
    print("1.0")
    print("EVENT:"+json.dumps(event))
    validate_uri = "https://keybase.io/_/api/1.0/sig/proof_valid.json?domain=%(identity_domain)s&kb_username=%(kb_username)s&username=%(identity_username)s&sig_hash=%(sig_hash)s" % {
        "identity_domain": os.environ.get("IdentityDomain"),
        "kb_username": event["queryStringParameters"]["kb_username"],
        "identity_username": event["queryStringParameters"]["username"],
        "sig_hash": event["queryStringParameters"]["token"]
    }
        
    print(validate_uri)
    print("1.1")
    keybase_response = requests.get(validate_uri)
    print("1.2")
    print("keybase_validproof_response" + keybase_response.text)
    if(keybase_response.ok):
        print("2.0")
        
        keybaseObj = json.loads(keybase_response.text)
        print("2.1")
        t = str(keybaseObj['proof_valid'])
        if( t.lower() == 'true'):
            print("T:3.0")
            notificationUri = os.environ.get("NotificationWebHook")
            dynamodbTableName = os.environ.get("dynamodb_table_validationproof")
            
            print('T:3.1')
            dynamodb = boto3.resource('dynamodb')
            table = dynamodb.Table(dynamodbTableName)
            print('looking for DynamoDB Table: '+ dynamodbTableName)

            # Print out some data about the table.
            # This will cause a request to be made to DynamoDB and its attribute
            # values will be set based on the response.
            table.put_item(
                Item={
                        'kb_username': event["queryStringParameters"]["kb_username"],
                        'username': event["queryStringParameters"]["username"],
                        'kb_ua': event["queryStringParameters"]["kb_ua"],
                        'token': event["queryStringParameters"]["token"]
                }
            )
            print('T:3.2 - about to redirect')
            # redirectLocation = os.environ.get("oauth_authorise_endpoint") + '?response_type=id_token&scope=openid+user.read+profile&client_id=' + os.environ.get("oauth_validation_audience") + '&redirect_uri=https://' + os.environ.get("api_fqdn") + '/static/oauth_callback&nonce=' + uuid.uuid4()

            # redirectLocation = os.environ.get("oauth_authorise_endpoint") + '?response_type=id_token&scope=openid+user.read+profile&client_id=' + os.environ.get("oauth_validation_audience") + '&redirect_uri=https://' + os.environ.get("api_fqdn") + '/static/oauth_callback&nonce=' + str(uuid.uuid4())
            redirectLocation = "%(oauth_authorise_endpoint)s?response_type=id_token&scope=openid+user.read+profile&client_id=%(oauth_validation_audience)s&redirect_uri=https://%(api_fqdn)s/static/oauth_callback&nonce=%(nonce)s" % {
                "oauth_authorise_endpoint": os.environ.get("oauth_authorise_endpoint"),
                "oauth_validation_audience": os.environ.get("oauth_validation_audience"),
                "api_fqdn" : os.environ.get("api_fqdn"),
                "nonce": str(uuid.uuid4())
            }

            return {
                'statusCode': 302,
                
                'headers': {

                    'location' : redirectLocation
                }
            }
        else:
            print("F:3.0")
            return {
                'statusCode': 400,
                'body': 'KEYBASE PROOF INVALID',
                'RequestId': context.aws_request_id,
                'Keybase_Respnse': keybase_response.text
            }
    else:
        print("NOT VALID SIG")
        return {
            'statusCode': 400,
            'body': 'FAILED KEYBASE PROOF REQUEST',
            'RequestId': context.aws_request_id,
            'Keybase_Respnse': keybase_response.text
        }
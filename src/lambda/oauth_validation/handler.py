import json,os,boto3,jwcrypto,time
from botocore.vendored import requests
from boto3.dynamodb.conditions import Key, Attr
# import requests
from jwcrypto import jwt, jwk, common


def lambda_handler(event, context):

    identity_domain = os.environ.get('identity_domain')
    cacheTTL = 900
    oidc_jwks_uri = os.environ.get("oidc_jwks_uri")
    print("1.0")
    # jwsToken.deserialize(token, key=signKey)
    
    # response = requests.get(os.environ.get("oidc_uri"))

    # oidc = json.loads(response.text)
    timestampFilePath = '/tmp/timestamp.jwks'
    jwksetFilePath = '/tmp/keys.jwks'


    if os.path.exists(timestampFilePath):
        f = open(timestampFilePath,'r+')
        cacheTimestamp = int(f.readline().strip())
        if (int(time.time()) - cacheTTL) > cacheTimestamp:
            f.seek(0)
            f.write(str(int(time.time())))
            f.truncate()
            f2 = open(jwksetFilePath,'w')
            f2.seek(0)
            f2.write(requests.get(oidc_jwks_uri).text)
            f2.truncate()
            f2.close()
            print("JWKSET CACHE REFRESHED")
        else:
            print("USING JWKSET CACHE")
        f.close()
    else:
        print("CREATING JWKSET CACHE")
        f = open(timestampFilePath, "w")
        f2 = open(jwksetFilePath,'w')
        f2.seek(0)
        f2.write(requests.get(oidc_jwks_uri).text)
        f2.truncate()
        f.write(str(int(time.time())))
        f.close()
        f2.close()




    f = open(jwksetFilePath)
    jwkset = f.read()
    f.close()

    
    # jwkset = requests.get(os.environ.get("oidc_jwks_uri")).text
    t = jwcrypto.jwk.JWKSet()
    t.import_keyset(jwkset)

    # e = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImllX3FXQ1hoWHh0MXpJRXN1NGM3YWNRVkduNCJ9.eyJhdWQiOiIwNWNlNjdkMi1hNTZlLTRiYTktYmY5Mi02MzEyOGEwY2MyYjkiLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vM2QwYWU5ZWMtODI1OC00ZTQzLTkwMjItOWRkNGQzODQ1YzZjL3YyLjAiLCJpYXQiOjE1NjkwOTkzMDEsIm5iZiI6MTU2OTA5OTMwMSwiZXhwIjoxNTY5MTAzMjAxLCJhaW8iOiJBV1FBbS84TUFBQUFPZ0RHSk9Yb0RvTkpWREViZkRoblR4K1luYUVORG5WMkNjZXYzWHU0OGpGSTlSK3EzejdoSUJOeExKa0dmZkdNWGg0TGgvZXZuRlpQUFhYRkJtY29GanMyd0RRd2JPRElnN1BsanQ0ZkxuazNpMmpxb0JUVUNLTlYybnZaQkFOTCIsIm5hbWUiOiJSaHlzIEV2YW5zIiwibm9uY2UiOiIyZTZkYmEyZC03M2VmLTQ4Y2QtYTBhZS0zOGU2NmU5YzA2MjkiLCJvaWQiOiI1NzdjYTFmNi0xYzE2LTQ1Y2EtODg4Mi00MzgxZTZkOGViY2QiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJyaHlzQGNvcmVmbHV4Lm9ubWljcm9zb2Z0LmNvbSIsInN1YiI6IkpIYVlPNWJ1TWNjMFBIcWxjSjB2TlNlcURjeVBDN18wNERMZjRva0p4RG8iLCJ0aWQiOiIzZDBhZTllYy04MjU4LTRlNDMtOTAyMi05ZGQ0ZDM4NDVjNmMiLCJ1dGkiOiJtck1YaUtlSU9rNm9BVHowZTFnUUFBIiwidmVyIjoiMi4wIn0.xcIfl_hbhIEYVDWo70N_95fFtRWzLxb4TnLX6KRd1lWBDnn4WP2Hob4S1oV2P6jTAlISovi1VQdiYB-vljRburET1OU6HNG0QAfbYuz_40NtsQeMgoeYg_up3wxWn-htPeyBl7Xg_GL0cfV9a2a7B9IYpwasQlZD-BqnfGr1rp1iC0t9QvOucRwRBP9g1s9l5lNQdQ2qtebvlFA80zxmPvxJwYe1vcx8onqGN0kaRrd3Kn9HpxyA-sVp9c7nVehpqlwV7qvg7aDFivOD2UlqJASv330KNEFo1kmMAlK0gyvqAwAsyo5wIKLnWMLqF43u4GiPVCvBlAFY5KQDaDKXDg'
    token = event["queryStringParameters"]["id_token"]
    ET = jwcrypto.jwt.JWT(key=t, jwt=token)

    # ST = jwt.JWT(key=jwkset, jwt=ET.claims)
    Token = json.loads(ET.claims)
    # if os.environ.get("IdentityDomain") == Token[""]
    if os.environ.get("oauth_validation_issuer") != Token["iss"]:
        print("INVALID TOKEN ISSUER") 
    elif os.environ.get("oauth_validation_audience")  != Token["aud"]:
        print("INVALID TOKEN AUDIENCE")
    else:
        print("VALID TOKEN")
        preferred_username = Token["preferred_username"].split("@")[0]
        print("PREFERRED_USERNAME:" + preferred_username)

        dynamodb_resource = boto3.resource('dynamodb')
        validationTable = dynamodb_resource.Table(os.environ.get('dynamodb_table_validationproof'))
        proofTable = dynamodb_resource.Table(os.environ.get('dynamodb_table_proof'))
        response = validationTable.scan(
            FilterExpression=Attr("username").eq(preferred_username)
        )
        

        if len(response["Items"]) == 1:
            print("DELETING OLD KB_USERNAME")
            validationTable.delete_item(
                Key={
                    'kb_username': response["Items"][0]["kb_username"]
                }
            )
            response["Items"][0]["identity_domain"] = os.environ.get('IdentityDomain')
            response["Items"][0]["last_update"] = str(int(time.time()))
            proofTable.put_item(
                Item=response["Items"][0]
            )
            return {
                'statusCode': 200,
                'body': 'User Identity Confirmed',
                'headers': {
                    'content-type':'application/json',
                    'Accept':'*/*'
                }
                # 
            }
        else:
            print(str(len(response["Items"])) + " users found in validationTable")
    return {
        'statusCode': 400,
        'body': 'SOMETHING WENT WRONG',
        'headers': {
            'content-type':'application/json',
            'Accept':'*/*'
        }
        # 
    }

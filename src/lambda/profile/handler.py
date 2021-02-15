import json,os,boto3,time
# from botocore.vendored import requests
from boto3.dynamodb.conditions import Key, Attr

def lambda_handler(event, context):


    dynamodb_resource = boto3.resource('dynamodb')
    validationTable = dynamodb_resource.Table(os.environ.get('dynamodb_table_validationproof'))
    proofTable = dynamodb_resource.Table(os.environ.get('dynamodb_table_proof'))
    response = validationTable.scan(
        FilterExpression=Attr("username").eq(event["pathParameters"]["profile"])
    )
    if len(response["Items"]) > 0:
        print("USERNAME:"+event["pathParameters"]["profile"])    
    
    
        return {
            'statusCode': 302,
            'headers': {
                'location' : 'https://keybase.io/'+event["pathParameters"]["profile"]
            }
        }
    else:
        return {
            'statusCode': 400,
            'body': 'NOT VALID ID'
        }

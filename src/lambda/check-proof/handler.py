import json,os,boto3, time
from boto3.dynamodb.conditions import Key, Attr




def lambda_handler(event, context):
    print("EVENT:"+json.dumps(event))
    # print("CONTEXT:"+json.dumps(context))#not serialisable
    dynamodb_resource = boto3.resource('dynamodb')
    proofTable = dynamodb_resource.Table(os.environ.get("dynamodb_table_proof"))

    response = proofTable.scan(
        FilterExpression=Attr("username").eq('rhys')
    )
    if len(response["Items"]) > 0:

        lst = []
        for item in response["Items"]:
            lst.append({
                "kb_username": item["kb_username"],
                "sig_hash": item["token"]
            })

        l = {
            "signatures": lst
        }
        
        return {
            'statusCode': 200,
            'body': json.dumps(l),
        }
    else:
        return {
            'statusCode': 400,
            'body': "INVALID ACCOUNT ID",
        }
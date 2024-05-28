import json
import boto3
import os
from botocore.exceptions import ClientError

# Initialize the DynamoDB client
client = boto3.client('dynamodb')

# Access environment variables
TableName = os.environ.get('databaseName')
partition_key = "stat"

def lambda_handler(event, context):
    try:
        # Attempt to retrieve the current view count
        current_view_response = client.get_item(
            TableName=TableName,
            Key={partition_key: {'S': 'view-count'}}
        )
        if 'Item' in current_view_response and 'Quantity' in current_view_response['Item']:
            # If the Quantity exists, get the current count
            current_view_count = int(current_view_response['Item']['Quantity']['N'])
        else:
            # Initialize the count if it doesn't exist
            current_view_count = 0
        
        # Increment the view count
        newCount = current_view_count + 1
        
        # Update the item in the DynamoDB table with the new count
        client.update_item(
            TableName=TableName,
            Key={partition_key: {'S': 'view-count'}},  # Use the partition_key variable
            UpdateExpression='SET Quantity = :val',
            ExpressionAttributeValues={':val': {'N': str(newCount)}},
            ReturnValues='UPDATED_NEW'
        )
    except ClientError as error:
        print(error)
        raise
    
    # Return the new view count in the response
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
        },
        'body': json.dumps({'count': newCount})
    }
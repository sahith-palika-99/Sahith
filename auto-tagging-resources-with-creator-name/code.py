import json
import boto3
def lambda_handler(event, context):
    # TODO implement
    client = boto3.client('cloudtrail')
    
    resource_type = event["detail"]["configurationItem"]["resourceType"]
    resource_arn = event["resources"][0]
    
    if resource_type == "AWS::Lambda::Function":
        resource_name = event["detail"]["configurationItem"]["configuration"]["functionName"]
        
        response = client.lookup_events(
        LookupAttributes=[
            {
                'AttributeKey': 'ResourceName',
                'AttributeValue': resource_name
            },
        ],
        )
        user_name=response["Events"][0]["Username"]
        
        client = boto3.client('lambda')
        
        client.tag_resource(
            Resource=resource_arn,
            Tags={'Created_by': user_name}
            )
        print("Lambda function "+resource_name+" tagged with username = " + user_name)
    
    elif resource_type == "AWS::EC2::Instance":
        print('hi')
        resource_name = event["detail"]["configurationItem"]["configuration"]["instanceId"]
        print(resource_name)
       
        
        response = client.lookup_events(
        LookupAttributes=[
            {
                'AttributeKey': 'ResourceName',
                'AttributeValue': resource_name
            },
        ],
        )
        user_name=response["Events"][0]["Username"]
        
        client = boto3.client('ec2')
        client.create_tags(
            Resources=[ resource_name ],
            Tags=[
                {
                    'Key': 'Created_by',
                    'Value': user_name
                },
            ])
        print("EC2 Instance "+resource_name+" tagged with username = " + user_name)
    
        
        
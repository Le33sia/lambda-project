import boto3
import json
import os
from datetime import datetime
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')
iam_client = boto3.client('iam')
report_bucket = os.environ['REPORT_BUCKET']

def lambda_handler(event, context):
    report = {} 


    # List all S3 buckets and their policies
    buckets = s3_client.list_buckets().get('Buckets', [])
    bucket_policies = {}
    for bucket in buckets:
        name = bucket['Name']
        try:
            policy = s3_client.get_bucket_policy(Bucket=name)['Policy']
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'NoSuchBucketPolicy':
                policy = None
            else:
                raise
        bucket_policies[name] = policy
    report['s3_bucket_policies'] = bucket_policies

    # List IAM roles
    roles = iam_client.list_roles().get('Roles', [])
    role_names = [role['RoleName'] for role in roles]
    report['iam_roles'] = role_names

    # Generate report file
    report_key = f"compliance_report_{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}.json"
    s3_client.put_object(
        Bucket=report_bucket,
        Key=report_key,
        Body=json.dumps(report, indent=2),
        ContentType='application/json'
    )

    return {
        'statusCode': 200,
        'body': f"Compliance report generated: s3://{report_bucket}/{report_key}"
    }

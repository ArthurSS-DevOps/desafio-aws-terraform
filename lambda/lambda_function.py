import boto3
import os
from datetime import datetime, timezone

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    

    bucket_name = os.environ['BUCKET_NAME']
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d_%H-%M-%S")

    s3.put_object(
        Bucket=bucket_name,
        Key=f"{now}.txt",
        Body="Arquivo criado automaticamente"
    )



    return {
        'statusCode': 200,
        'body': 'Arquivo criado com sucesso'
    }
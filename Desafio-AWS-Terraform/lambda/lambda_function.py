import boto3
import os
from datetime import datetime
from zoneinfo import ZoneInfo

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    bucket_name = os.environ['BUCKET_NAME']

    now = datetime.now(ZoneInfo("America/Sao_Paulo")).strftime("%Y-%m-%d_%H-%M-%S")

    s3.put_object(
        Bucket=bucket_name,
        Key=f"{now}.txt",
        Body="Arquivo criado automaticamente"
    )
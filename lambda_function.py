import json
import os
import urllib.request
import boto3
import uuid


def get_openweather_key():
    secret_name = "smart-plant-openweather-api-key"
    region_name = "us-east-1"

    client = boto3.client("secretsmanager", region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)

    secret_data = json.loads(response["SecretString"])
    return secret_data["OPENWEATHER_API_KEY"]


def lambda_handler(event, context):
    api_key = get_openweather_key()
    
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("smart-plant-history")

    query_params = event.get("queryStringParameters") or {}
    city = query_params.get("city", "Leipzig")
    url = (
        "https://api.openweathermap.org/data/2.5/weather"
        f"?q={city}&appid={api_key}&units=metric"
    )

    with urllib.request.urlopen(url) as response:
        weather_data = json.loads(response.read().decode())

    temperature = weather_data["main"]["temp"]
    humidity = weather_data["main"]["humidity"]
    weather_description = weather_data["weather"][0]["description"]

    if humidity > 80 or "rain" in weather_description.lower():
        advice = "Do not water today"
    else:
        advice = "Water today"

    result = {
        "city": city,
        "temperature": temperature,
        "humidity": humidity,
        "weather": weather_description,
        "watering_advice": advice,
    }
    
    table.put_item(
    Item={
        "PlantID": str(uuid.uuid4()),
        "city": city,
        "temperature": str(temperature),
        "humidity": str(humidity),
        "weather": weather_description,
        "watering_advice": advice,
    }
)

    return {
        "statusCode": 200,
        "body": json.dumps(result),
    }
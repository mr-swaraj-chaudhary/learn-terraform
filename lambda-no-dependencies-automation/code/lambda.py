def lambda_handler(event, context):
    message = f"Hello {event['message']}"
    return {
        'message': message
    }
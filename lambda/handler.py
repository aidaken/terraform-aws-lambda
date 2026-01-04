import json
import os
from datetime import datetime, timezone

def handler(event, context):
    log = {
        "level": "INFO",
        "service": "tf-portfolio-hello",
        "message": "lambda invoked",
        "requestId": getattr(context, "aws_request_id", None),
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    print(json.dumps(log))

    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({"ok": True, "service": "tf-portfolio-hello"})
    }


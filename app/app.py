from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = socket.gethostname()
    return jsonify(
        message="Hello World + Enterprise Vibe Coding",
        hostname=hostname,
        environment=os.environ.get("ENVIRONMENT", "development")
    )

if __name__ == '__main__':
    # Use port 8080 for Kubernetes compatibility
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))

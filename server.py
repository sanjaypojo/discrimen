from flask import Flask, request, abort, jsonify, Response
import os
import json

app = Flask(__name__)


@app.route('/app.js')
def app_js():
    return app.send_static_file('app.js')


@app.route('/')
def app_html():
    return app.send_static_file('app.html')


if __name__ == '__main__':
    app.run(debug=True)

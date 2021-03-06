from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
session = requests.Session()

calculatorUrl = 'http://172.16.0.4:5000/'

@app.route('/<operation>', methods = ['GET', 'POST'])
def user(operation):
    if request.method == 'GET':
        return {"value": "get method returns no data"}
    if request.method == 'POST':
        data = request.json
        calculatorRes = session.post(calculatorUrl+'calculate/'+operation, verify=True, json=data, allow_redirects=False)
        result = {"result": calculatorRes.json()}
        return result
    else:
        return {'value': 'no data'}

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080, debug=True)

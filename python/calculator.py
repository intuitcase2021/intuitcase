from flask import Flask, request, jsonify

app = Flask(__name__)
@app.route('/calculate/<operation>', methods = ['GET', 'POST'])
def user(operation):
    if request.method == 'GET':
        return {"value": "no data"}
    if request.method == 'POST':
        data = request.json
        result = ()
        if operation == 'add':
            result = add(data['number1'],data['number2'])
        elif operation == 'sub':
            result = subtract(data['number1'],data['number2'])
        return jsonify(result)
    else:
        return 0

def add(number1, number2):
    return number1+number2

def subtract(number1, number2):
    return number1-number2

if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)

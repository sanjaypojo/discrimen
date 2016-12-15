from flask import Flask, request, abort, jsonify, Response
import os
import json
import pandas as pd
import random
import numpy as np
import math
import itertools

app = Flask(__name__)


def ageist_pricer(model_input):
    if model_input['age'] > 50 and model_input['age'] < 60 and model_input['gender'] == "f":
        return 2499*(1 + (0.01*random.randint(-10,10)))
    else:
        return 2399*(1 + (0.01*random.randint(-10,10)))

algorithm_list = [
    {
        'id': '1',
        'name': 'Textbook Pricer',
        'model': ageist_pricer,
        'type': 'continuous',
        'schema': [
            {
                'name': 'gender',
                'type': 'discrete',
                'options': ['m', 'f'],
            },
            {
                'name': 'age',
                'type': 'continuous',
                'is_integer': False,
                'min': 12,
                'max': 98,
            },
            {
                'name': 'buys_per_month',
                'type': 'continuous',
                'is_integer': True,
                'min': 0,
                'max': 235,
            },
            {
                'name': 'spend_per_month',
                'type': 'continuous',
                'is_integer': False,
                'min': 0,
                'max': 35000,
            }
        ],
    }
]


def get_algorithm(algo_id):
    for algorithm in algorithm_list:
        if int(algorithm['id']) == int(algo_id):
            return algorithm
    return None


def analyze_algorithm(algo_id, sensitive_field_name):
    # Get the chosen algorithm
    chosen_algorithm = get_algorithm(algo_id)
    if chosen_algorithm is None:
        return {'err': True, 'result': None, 'error_message': 'Invalid algorithm ID'}

    # Separate the sensitive field from other fields
    other_fields = []
    sensitive_field = None

    for item in chosen_algorithm['schema']:
        if item['name'] == sensitive_field_name and item['type'] == 'discrete':
            sensitive_field = item
        else:
            other_fields.append(item)
    if sensitive_field is None:
        return {'err': True, 'result': None, 'error_message': 'Invalid sensitive field'}

    # Generate samples for each dimension independently
    samples = []
    num_of_samples = 10 ^ int(math.ceil(9 / len(other_fields)))
    for input_field in other_fields:
        if input_field['type'] == 'continuous':
            samples.append(
                np.linspace(input_field['min'], input_field['max'], num_of_samples)
            )
        else:
            samples.append(input_field['options'])

    # Construct an input vector space using all possible combinations
    rows = []
    for sample in itertools.product(*samples):
        model_input = {}
        output = {}
        df_row = {}
        for index, input_field in enumerate(other_fields):
            model_input[input_field['name']] = sample[index]

        df_row.update(model_input)
        for sfo in sensitive_field['options']:
            model_input[sensitive_field['name']] = sfo
            output['output_' + sfo] = chosen_algorithm['model'](model_input)

        df_row.update(output)
        rows.append(df_row)

    # DataFrame contains all generated inputs
    # and output sets for each class of the sensitive_field
    df = pd.DataFrame(rows)
    return {'err': False, 'result': df}


@app.route('/app.js')
def app_js():
    return app.send_static_file('app.js')


@app.route('/')
def app_html():
    return app.send_static_file('app.html')


@app.route('/api/algorithms')
def api_list_algorithms():
    algorithms_json = []
    for item in algorithm_list:
        algorithms_json.append(
            {
                'id': item['id'],
                'name': item['name'],
                'schema': item['schema']
            }
        )
    return jsonify(algorithms_json)


@app.route('/api/algorithms/<int:algo_id>')
def api_analyze_algorithm(algo_id):
    print(algo_id)
    analysis = analyze_algorithm(algo_id, 'gender')

    if analysis['err']:
        return jsonify(analysis)
    else:
        return jsonify(
            analysis['result'].describe().to_json()
        )


if __name__ == '__main__':
    app.run(debug=True)

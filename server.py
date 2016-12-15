from flask import Flask, request, abort, jsonify, Response
import os
import json
import pandas as pd
import random
import numpy as np
import math
import itertools

app = Flask(__name__)


def insurance_pricer(model_input):
    if model_input['age'] > 50 and model_input['age'] < 55 and model_input['gender'] == "f":
        return 2449 * (1 + (0.01 * random.randint(-10, 10)))
    elif model_input['age'] > 20 and model_input['age'] < 25 and model_input['gender'] == "m":
        return 2449 * (1 + (0.01 * random.randint(-10, 10)))
    else:
        return 2399 * (1 + (0.01 * random.randint(-10, 10)))


def danger_predictor(model_input):
    base_score = model_input['prior_offenses_class_1'] / 10
    base_score += model_input['prior_offenses_class_2'] / 100
    base_score += 25 / model_input['age']
    prediction = random.randint(math.floor(base_score),10)
    if model_input['age'] < 30 and model_input['race'] == "y":
        return min(prediction + 1, 10)
    elif (model_input['prior_offenses_class_3'] > 45 or model_input['prior_offenses_class_2'] > 40) and model_input['race'] == "z":
        return min(prediction + 1, 10)
    else:
        return prediction


algorithm_list = [
    {
        'id': '1',
        'name': 'Insurance Pricer',
        'model': insurance_pricer,
        'type': 'continuous',
        'output': 'Insurance Premium (USD)',
        'sensitive_field': 'gender',
        'schema': [
            {
                'name': 'gender',
                'type': 'discrete',
                'options': ['m', 'f'],
            },
            {
                'name': 'age',
                'type': 'continuous',
                'min': 12,
                'max': 98,
            },
            {
                'name': 'hospital_visits',
                'type': 'continuous',
                'min': 0,
                'max': 100,
            },
            {
                'name': 'daily_calorie_avg',
                'type': 'continuous',
                'min': 0,
                'max': 1000,
            },
            {
                'name': 'no_claim_rate',
                'type': 'continuous',
                'min': 0,
                'max': 1,
            }
        ],
    },
    {
        'id': '2',
        'name': 'Redicivism Predictor',
        'model': danger_predictor,
        'type': 'continuous',
        'output': 'Risk Level',
        'sensitive_field': 'race',
        'schema': [
            {
                'name': 'race',
                'type': 'discrete',
                'options': ['w', 'x', 'y', 'z'],
            },
            {
                'name': 'prior_offenses_class_1',
                'type': 'continuous',
                'min': 0,
                'max': 50,
            },
            {
                'name': 'prior_offenses_class_2',
                'type': 'continuous',
                'min': 0,
                'max': 50,
            },
            {
                'name': 'prior_offenses_class_3',
                'type': 'continuous',
                'min': 0,
                'max': 50,
            },
            {
                'name': 'age',
                'type': 'continuous',
                'min': 18,
                'max': 95,
            }
        ],
    }
]


def get_algorithm(algo_id):
    for algorithm in algorithm_list:
        if int(algorithm['id']) == int(algo_id):
            return algorithm
    return None


def analyze_algorithm(algo_id):
    # Get the chosen algorithm
    chosen_algorithm = get_algorithm(algo_id)
    sensitive_field_name = chosen_algorithm['sensitive_field']
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
    num_of_samples = 30
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

    # Construct individual frames of output vs each variable
    output_fields = ['output_' + sf for sf in sensitive_field['options']]
    binned_results = bin_results(df, other_fields, output_fields)

    return {'err': False, 'result': df, 'binned_results': binned_results}


def bin_results(df, other_fields, output_fields):
    binned_results = []
    for field in other_fields:
        field_list = [field['name']]
        field_list.extend(output_fields)
        print(field_list)
        binned_df = df[field_list].copy()
        bins = np.linspace(field['min'], field['max'], 20)
        binned_df[field['name'] + '_bins'] = pd.cut(binned_df[field['name']], bins)
        binned_df = binned_df.groupby([field['name'] + '_bins']).mean()
        binned_results.append(binned_df.to_json())
    return binned_results


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
                'schema': item['schema'],
                'output': item['output']
            }
        )
    return jsonify(algorithms_json)


@app.route('/api/algorithms/<int:algo_id>')
def api_analyze_algorithm(algo_id):
    analysis = analyze_algorithm(algo_id)

    if analysis['err']:
        return jsonify(analysis)
    else:
        return jsonify(
            analysis['binned_results']
        )


if __name__ == '__main__':
    app.run(debug=True)

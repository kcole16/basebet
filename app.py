#!flask/bin/python
from flask import Flask, jsonify, request, render_template, redirect, Response
from mlb import fetch_scores, fetch_games


app = Flask(__name__)

"""UI Routes"""

@app.route('/final_scores/', methods=['GET'])
def final_scores():
    month = request.args['month']
    day = request.args['day']
    scores = fetch_scores(month, day)
    if scores:
        return jsonify(scores=scores)
    else:
        return jsonify(500)

@app.route('/get_games/', methods=['GET'])
def get_games():
    month = request.args['month']
    day = request.args['day']
    games = fetch_games(month, day)
    if games:
        return jsonify(games=games)
    else:
        return jsonify(500)

"""Run server"""
if __name__ == '__main__':
    app.run(debug = True)
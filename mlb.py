import requests
import parser

def get_scores(game):
    home = 0
    away = 0
    try:
        innings = game['linescore']['inning']
    except KeyError:
        return None
    for inning in innings:
        try:
            home += int(inning['home'])
        except KeyError:
            home += 0
        try: 
            away += int(inning['away'])
        except KeyError:
            away += 0
    return {'home': home, 'away': away}

def parse_scores(games):
    parsed_scores = {}
    for game in games['game']:
        scores = get_scores(game)
        if scores:
            home_team = {
                'name': game['home_team_name'],
                'score': scores['home']
            }
            away_team = {
                'name': game['away_team_name'],
                'score': scores['away']
            }
            winner = home_team['name'] if home_team['score'] > away_team['score'] else away_team['name']
            parsed_scores[game['game_pk']] = {
                'home': home_team,
                'away': away_team,
                'winner': winner
            }
    return parsed_scores

def parse_games(games):
    parsed_games = []
    for game in games['game']:
        if 'linescore' not in game:
            parsed_games.append({
                'pk': game['game_pk'],
                'home': game['home_team_name'],
                'away': game['away_team_name']
            })
    return parsed_games

def fetch_scores(month, day):
    url = 'http://gd2.mlb.com/components/game/mlb/year_2017/month_%s/day_%s/master_scoreboard.json' % (month, day)
    r = requests.get(url)
    if r.ok:
        scores = parse_scores(r.json()['data']['games'])
    else:
        scores = None
    return scores

def fetch_games(month, day):
    url = 'http://gd2.mlb.com/components/game/mlb/year_2017/month_%s/day_%s/master_scoreboard.json' % (month, day)
    r = requests.get(url)
    if r.ok:
        games = parse_games(r.json()['data']['games'])
    else:
        games = None
    return games

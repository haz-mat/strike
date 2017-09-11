import subprocess
from os import path
from os import environ

from flask import Flask
from flask import abort
from flask import request

app = Flask(__name__)
app.config.from_object(__name__)

if environ['STRIKE_SRV_DIR']:
    srv_dir = environ['STRIKE_SRV_DIR']
else:
    srv_dir = './'

app.config.update(dict(
    SRV_DIR=srv_dir
))
app.static_url_path = path.join(app.config['SRV_DIR'], 'static')


@app.route('/ignition/<string:cfg>', methods=['GET'])
def ct_transpile(cfg):
    if path.isfile(path.join(app.config['SRV_DIR'],
                   'ignition', cfg + '.yaml')):
        cfg_file = path.join(app.config['SRV_DIR'],
                             'ignition', cfg + '.yaml')
    elif path.isfile(path.join(app.config['SRV_DIR'],
                               'ignition', cfg + '.yml')):
        cfg_file = path.join(app.config['SRV_DIR'],
                             'ignition', cfg + '.yml')
    elif path.isfile(path.join(app.config['SRV_DIR'],
                               'ignition', cfg + '.ignition')):
        cfg_file = path.join(app.config['SRV_DIR'],
                             'ignition', cfg + '.ignition')
    elif path.isfile(path.join(app.config['SRV_DIR'],
                               'ignition', cfg + '.ign')):
        cfg_file = path.join(app.config['SRV_DIR'],
                             'ignition', cfg + '.ign')
    elif path.isfile(path.join(app.config['SRV_DIR'],
                               'ignition', cfg + '.json')):
        cfg_file = path.join(app.config['SRV_DIR'],
                             'ignition', cfg + '.json')
    else:
        abort(404)

    cmd = ['./bin/ct']
    platform = request.args.get('platform')
    try:
        cmd.append('-platform=' + platform)
    except:
        pass

    proc = subprocess.Popen(cmd,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            stdin=subprocess.PIPE)
    out, err = proc.communicate(open(cfg_file, 'rb').read())
    if proc.returncode != 0:
        abort(500, err.decode('unicode_escape'))
    response = app.response_class(
        response=out,
        status=200,
        mimetype='application/json'
    )
    return response

#!/usr/bin/env python3
from flask import Flask, request, jsonify, Response
from pymongo import MongoClient
import json

app = Flask(__name__)
db = MongoClient("mongodb://127.0.0.1:27017/").oops

@app.route("/")
def index():
    return ("<h1>OOPS Corp — Panell</h1>"
            "<p>API interna. Autentica't a <a href='/login'>/login</a>.</p>"
            "<!-- dev: recorda esborrar /backup i /api/debug abans de produccio -->")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return ("<form method=post>"
                "user <input name=username> pass <input name=password type=password>"
                "<button>entrar</button></form>")
    # VULNERABLE a NoSQL injection si s'envia JSON:
    #   {"username":"admin","password":{"$ne":null}}
    data = request.get_json(silent=True) or request.form.to_dict()
    u = data.get("username"); p = data.get("password")
    doc = db.users.find_one({"username": u, "password": p})
    if doc:
        return jsonify(ok=True, msg="Benvingut " + str(doc.get("username")),
                       hint="mira /backup")
    return jsonify(ok=False), 401

# Ruta "oculta" descobrible amb gobuster -> filtra la clau de xifratge
@app.route("/backup")
def backup():
    return Response(
        "# backup config\n"
        "MONGO_URI=mongodb://127.0.0.1:27017/\n"
        "DATA_ENC_KEY=Sup3rMongoKey_2024\n"
        "# TODO: el hash de root esta a la col.leccio 'system_secrets'\n",
        mimetype="text/plain")

# Endpoint de "debug" que aboca col·leccions (també descobrible amb gobuster)
@app.route("/api/debug")
def debug():
    out = {}
    for c in ["users", "secure_docs", "system_secrets"]:
        out[c] = list(db[c].find({}, {"_id": 0}))
    return app.response_class(json.dumps(out, indent=2), mimetype="application/json")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

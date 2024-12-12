
from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

def init_db():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS learners (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            ENG INTEGER NOT NULL,
            MATH INTEGER NOT NULL,
            KISW INTEGER NOT NULL,
            SCIE INTEGER NOT NULL,
            SST INTEGER NOT NULL,
            total INTEGER NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

@app.before_first_request
def setup():
    init_db()

@app.route('/api/learners', methods=['GET'])
def get_learners():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('SELECT id, name, ENG, MATH, KISW, SCIE, SST, total FROM learners ORDER BY total DESC')
    learners = cursor.fetchall()
    conn.close()

    return jsonify([
        {
            "id": learner[0],
            "name": learner[1],
            "marks": {
                "ENG": learner[2],
                "MATH": learner[3],
                "KISW": learner[4],
                "SCIE": learner[5],
                "SST": learner[6],
            },
            "total": learner[7]
        }
        for learner in learners
    ])

@app.route('/api/learners', methods=['POST'])
def add_learner():
    data = request.get_json()
    name = data.get('name')
    ENG = data.get('ENG')
    MATH = data.get('MATH')
    KISW = data.get('KISW')
    SCIE = data.get('SCIE')
    SST = data.get('SST')

    if not all([name, ENG, MATH, KISW, SCIE, SST]):
        return jsonify({"error": "Missing data"}), 400

    total = ENG + MATH + KISW + SCIE + SST

    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute(
        'INSERT INTO learners (name, ENG, MATH, KISW, SCIE, SST, total) VALUES (?, ?, ?, ?, ?, ?, ?)',
        (name, ENG, MATH, KISW, SCIE, SST, total)
    )
    conn.commit()
    conn.close()

    return jsonify({"message": "Learner added successfully"}), 201

@app.route('/api/learners/<int:learner_id>', methods=['GET'])
def get_learner(learner_id):
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('SELECT id, name, ENG, MATH, KISW, SCIE, SST, total FROM learners WHERE id = ?', (learner_id,))
    learner = cursor.fetchone()
    conn.close()

    if learner is None:
        return jsonify({"error": "Learner not found"}), 404

    return jsonify({
        "id": learner[0],
        "name": learner[1],
        "marks": {
            "ENG": learner[2],
            "MATH": learner[3],
            "KISW": learner[4],
            "SCIE": learner[5],
            "SST": learner[6],
        },
        "total": learner[7]
    })

if __name__ == '__main__':
    app.run(debug=True)

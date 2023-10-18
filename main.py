from flask import Flask, request, jsonify, make_response
import sqlite3

app = Flask (__name__)

#db connection 
def get_db():
    connection = sqlite3.connect('user_id.db')
    return connection


# creat table for storing user ids
def db_init():
    connection = get_db()
    cursor = connection.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            firstName TEXT,
            lastName TEXT,
            age INTEGER
        )
    ''')
    connection.commit()
    connection.close # without this connection close getting threading issues, objects created in a thread can only be used in the same thread.
    

db_init()

@app.route("/get-user/<user_id>")
def get_user(user_id):
    connection = get_db()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    if user:
        user_id = {
            'id': user[0],
            'firstName': user[1],
            'lastName': user[2],
            'age': user[3]
        }

    # e = request.args.get("e")
    # if e:
    #     users["e"] = e
        cursor.close()
        connection.close()
        return jsonify(user_id), 200
    else:
        cursor.close()
        connection.close()
        return make_response(jsonify({"error": "User ID was not found"}), 404)

    # response = jsonify(users)
    # return make_response(response, 200)



# Recieve data in json format from request
@app.route("/create-user", methods=["POST"])
def create_user():
    data = request.get_json()

    if not data:
        return make_response(jsonify({"error": "Invalid request data"}), 400)
    
    connection = get_db()
    cursor = connection.cursor()
    
    try:
        cursor.execute("INSERT INTO users (firstName, lastName, age) VALUES (?, ?, ?)",
                       (data['firstName'], data['lastName'], data['age']))
        connection.commit()
        cursor.close()
        connection.close()
    except Exception as e:
        return make_response(jsonify({"error": f"Database error: {str(e)}"}), 500)
    
    response = jsonify(data)
    return make_response(response, 201)



if __name__ == "__main__":
    app.run(debug=True)



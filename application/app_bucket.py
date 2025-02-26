from flask import Flask, render_template, request, redirect, url_for
from google.cloud import storage
import os
import json
from uuid import uuid4
import sys

app = Flask(__name__)

# Configurer le bucket Cloud Storage
BUCKET_NAME = os.getenv("BUCKET_NAME")
if not BUCKET_NAME: 
    print(" Erreur : La variable d'environnement 'BUCKET_NAME' n'est pas définie.", file=sys.stderr) 
    sys.exit(1)  # Arrête le programme avec un code d'erreur

def get_storage_client():
    """Initialise le client Google Cloud Storage."""
    return storage.Client()

def list_notes():
    """Récupère toutes les notes depuis le bucket."""
    client = get_storage_client()
    bucket = client.bucket(BUCKET_NAME)
    blobs = bucket.list_blobs()
    notes = []
    
    for blob in blobs:
        content = blob.download_as_text()
        note = json.loads(content)
        notes.append(note)

    return notes

def save_note(note):
    """Enregistre une note dans le bucket."""
    client = get_storage_client()   
    bucket = client.bucket(BUCKET_NAME)
    note_id = str(uuid4())  # Génère un ID unique pour chaque note
    blob = bucket.blob(f"{note_id}.json")
    blob.upload_from_string(json.dumps(note), content_type='application/json')

@app.route('/')
def index():
    """Affiche la liste des notes."""
    notes = list_notes()
    return render_template('index.html', notes=notes)

@app.route('/add', methods=('GET', 'POST'))
def add_note():
    """Ajoute une nouvelle note."""
    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']
        note = {
            'title': title,
            'content': content
        }
        save_note(note)
        return redirect(url_for('index'))
    
    return render_template('add_note.html')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
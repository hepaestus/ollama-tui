from flask import Flask, render_template, request, jsonify, Response
import ollama
import threading
import time
import sys
from datetime import datetime

app = Flask(__name__)

# Store conversation history
conversations = {}
current_conversation_id = None

def get_model_list():
    """Get available models from Ollama"""
    try:
        response = ollama.list()
        # Handle both old dict format and new Model object format
        models = []
        for model in response.models if hasattr(response, 'models') else response['models']:
            if hasattr(model, 'model'):
                # New Model object format
                models.append(model.model)
            elif isinstance(model, dict) and 'name' in model:
                # Old dict format
                models.append(model['name'])
            else:
                # Fallback
                models.append(str(model))
        return models
    except Exception as e:
        return ["Error: " + str(e)]

def get_response(model, prompt, conversation_id):
    """Get response from Ollama"""
    try:
        if conversation_id not in conversations:
            conversations[conversation_id] = []
        
        # Add user message to conversation
        conversations[conversation_id].append({
            "role": "user",
            "content": prompt
        })
        
        # Get response from Ollama
        response = ollama.chat(
            model=model,
            messages=conversations[conversation_id],
            stream=False
        )
        
        # Add assistant response to conversation
        assistant_response = response['message']['content']
        conversations[conversation_id].append({
            "role": "assistant",
            "content": assistant_response
        })
        
        return assistant_response
    except Exception as e:
        return f"Error: {str(e)}"

@app.route('/')
def index():
    models = get_model_list()
    return render_template('index.html', models=models)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    model = data.get('model', 'llama3')
    prompt = data.get('prompt', '')
    conversation_id = data.get('conversation_id', 'default')
    
    response = get_response(model, prompt, conversation_id)
    return jsonify({"response": response})

@app.route('/new_conversation', methods=['POST'])
def new_conversation():
    global current_conversation_id
    current_conversation_id = str(time.time())
    return jsonify({"conversation_id": current_conversation_id})

@app.route('/conversations/<conversation_id>')
def get_conversation(conversation_id):
    if conversation_id in conversations:
        return jsonify(conversations[conversation_id])
    return jsonify([])

if __name__ == '__main__':
    print("Starting Flask app with Ollama backend...")
    print("Available models:", get_model_list())
    print("Visit http://localhost:5000 in your browser")
    app.run(host='0.0.0.0', port=5000, debug=True)

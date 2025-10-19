#!/usr/bin/env python3
"""
Debug test script for ollama-tui
This script tests both Flask and TUI components
"""

def test_flask_app():
    """Test Flask app components"""
    print("=== Testing Flask App ===")
    try:
        from app import get_model_list, get_response
        
        models = get_model_list()
        print(f"✓ Models loaded: {models}")
        
        if models and not models[0].startswith("Error"):
            test_model = models[0]
            print(f"✓ Testing chat with model: {test_model}")
            
            # Test response (simplified)
            response = get_response(test_model, "Hello, say hi back!", "test_conversation")
            print(f"✓ Response received: {response[:100]}...")
            
    except Exception as e:
        print(f"✗ Flask test failed: {e}")

def test_tui_imports():
    """Test TUI imports and basic functionality"""
    print("\n=== Testing TUI Imports ===")
    try:
        from tui import OllamaTUI
        print("✓ TUI imports successful")
        
        # Test instantiation
        app = OllamaTUI()
        print(f"✓ TUI app created, models: {app.models}")
        print(f"✓ Default model: {app.model}")
        
    except Exception as e:
        print(f"✗ TUI test failed: {e}")

def test_ollama_connection():
    """Test Ollama connection"""
    print("\n=== Testing Ollama Connection ===")
    try:
        import ollama
        response = ollama.list()
        print(f"✓ Ollama connected, found {len(response.models)} models")
        
        # Test a simple chat
        if response.models:
            test_model = response.models[0].model
            chat_response = ollama.chat(
                model=test_model,
                messages=[{"role": "user", "content": "Hi"}],
                stream=False
            )
            print(f"✓ Chat test successful with {test_model}")
        
    except Exception as e:
        print(f"✗ Ollama test failed: {e}")

if __name__ == "__main__":
    print("Running ollama-tui debug tests...")
    test_ollama_connection()
    test_flask_app() 
    test_tui_imports()
    print("\n=== Debug tests complete ===")
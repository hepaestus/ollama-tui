from textual.app import App, ComposeResult
from textual.containers import Container, Vertical, Horizontal
from textual.widgets import (
    Button, 
    Input, 
    Label, 
    Select, 
    TextArea,
    Footer,
    Header
)
from textual.binding import Binding
from textual.reactive import reactive
import ollama
import asyncio
from datetime import datetime
from typing import List, Dict, Any

class OllamaTUI(App):
    """Textual-based TUI for Ollama with proper widgets"""
    
    CSS_PATH = "tui.css"
    
    BINDINGS = [
        Binding("ctrl+c", "quit", "Quit"),
        Binding("ctrl+r", "reset", "Reset"),
    ]
    
    def __init__(self):
        super().__init__()
        self.conversation_history: List[Dict[str, str]] = []
        self.models = self.get_models()
        self.model = self.models[0] if self.models and not self.models[0].startswith("Error") else "llama3"
        self.conversation_id = str(datetime.now().timestamp())
        
    def get_models(self) -> List[str]:
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
    
    def compose(self) -> ComposeResult:
        """Compose the TUI layout"""
        yield Header()
        
        with Container(id="main-container"):
            with Horizontal():
                # Left panel - Model selection and controls
                with Container(id="left-panel"):
                    yield Label("Ollama Chat Interface", id="title")
                    yield Select(
                        [(model, model) for model in self.models],
                        id="model-select",
                        value=self.model
                    )
                    yield Button("New Chat", id="new-chat")
                    yield Button("Clear History", id="clear-history")
                    yield Button("Show History", id="show-history")
                
                # Right panel - Chat display and input
                with Container(id="right-panel"):
                    self.chat_display = TextArea(
                        "", 
                        id="chat-display",
                        read_only=True
                    )
                    yield self.chat_display
                    
                    with Horizontal():
                        self.input_field = Input(
                            placeholder="Type your message...",
                            id="message-input"
                        )
                        yield self.input_field
                        yield Button("Send", id="send-button")
        
        yield Footer()
    
    def on_mount(self) -> None:
        """Called when app is mounted"""
        self.chat_display.cursor_location = (0, 0)
        self.update_chat_display("Welcome to Ollama TUI!\nType a message or use the controls above.")
    
    def on_select_changed(self, event: Select.Changed) -> None:
        """Handle model selection change"""
        self.model = event.value
        self.update_chat_display(f"Model changed to: {self.model}")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button presses"""
        if event.button.id == "new-chat":
            self.new_chat()
        elif event.button.id == "clear-history":
            self.clear_history()
        elif event.button.id == "show-history":
            self.show_history()
        elif event.button.id == "send-button":
            self.send_message()
    
    def on_input_submitted(self, event: Input.Submitted) -> None:
        """Handle message submission via Enter key"""
        self.send_message()
    
    def new_chat(self) -> None:
        """Start a new conversation"""
        self.conversation_history = []
        self.conversation_id = str(datetime.now().timestamp())
        self.update_chat_display("New conversation started!")
    
    def clear_history(self) -> None:
        """Clear conversation history"""
        self.conversation_history = []
        self.update_chat_display("Conversation history cleared!")
    
    def show_history(self) -> None:
        """Show conversation history"""
        if not self.conversation_history:
            self.update_chat_display("No conversation history")
            return
        
        history_text = "Conversation History:\n"
        history_text += "-" * 40 + "\n"
        for i, msg in enumerate(self.conversation_history):
            role = msg['role']
            content = msg['content']
            history_text += f"{i+1}. {role.capitalize()}: {content}\n"
        history_text += "-" * 40 + "\n"
        
        self.update_chat_display(history_text)
    
    def update_chat_display(self, text: str) -> None:
        """Update the chat display area"""
        current_content = self.chat_display.text
        if current_content.strip():
            self.chat_display.text = current_content + "\n" + text
        else:
            self.chat_display.text = text
    
    def send_message(self) -> None:
        """Send a message to Ollama"""
        message = self.input_field.value.strip()
        if not message:
            return
        
        # Add user message to history
        self.conversation_history.append({
            "role": "user",
            "content": message
        })
        
        # Update display with user message
        self.update_chat_display(f"You: {message}")
        
        # Clear input
        self.input_field.value = ""
        
        # Get response from Ollama
        asyncio.create_task(self.get_ollama_response(message))
    
    async def get_ollama_response(self, user_message: str) -> None:
        """Get response from Ollama"""
        try:
            response = ollama.chat(
                model=self.model,
                messages=self.conversation_history,
                stream=False
            )
            
            assistant_response = response['message']['content']
            
            # Add assistant response to history
            self.conversation_history.append({
                "role": "assistant",
                "content": assistant_response
            })
            
            # Update display with assistant response
            self.update_chat_display(f"Assistant: {assistant_response}")
            
        except Exception as e:
            error_msg = f"Error: {str(e)}"
            self.update_chat_display(error_msg)
            self.log(error_msg)

if __name__ == "__main__":
    app = OllamaTUI()
    app.run()

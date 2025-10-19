# Ollama TUI

A dual-interface chat application for Ollama with both a **Terminal User Interface (TUI)** and a **Web Interface**. Chat with your local Ollama models through an intuitive terminal interface or a modern web browser.

## Features

- 🖥️ **Terminal User Interface** - Clean, responsive TUI built with Textual
- 🌐 **Web Interface** - Modern web-based chat interface using Flask
- 🤖 **Multi-Model Support** - Automatically detects and supports all your Ollama models
- 💬 **Conversation History** - Maintains chat context throughout conversations
- 🔄 **Model Switching** - Easy switching between different Ollama models
- 🎨 **Customizable Interface** - CSS styling for the TUI and responsive web design

## Prerequisites

Before installing ollama-tui, make sure you have:

1. **Python 3.8+** installed on your system
2. **Ollama** installed and running
   - Download from: https://ollama.ai/
   - At least one model downloaded (e.g., `ollama pull qwen3-code:30b`)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/hepaestus/ollama-tui.git
cd ollama-tui
```

### 2. Set Up Python Virtual Environment

It's recommended to use a virtual environment to avoid dependency conflicts:

```bash
# Create virtual environment
python3 -m venv .venv

# Activate virtual environment
# On Linux/macOS:
source .venv/bin/activate

# On Windows:
# .venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

Alternatively, install manually:

```bash
pip install flask textual ollama werkzeug jinja2 markupsafe itsdangerous click python-dotenv
```

## Quick Start with Startup Script

For the easiest setup and launch experience, use the included startup script that automates the entire process:

### Linux/macOS

```bash
# Make script executable (first time only)
chmod +x start.sh

# Interactive menu
./start.sh

# Or use direct commands:
./start.sh --setup    # Setup environment only
./start.sh --tui      # Setup and run Terminal UI
./start.sh --web      # Setup and run Web Interface  
./start.sh --both     # Setup and run both interfaces
./start.sh --test     # Setup and run diagnostic tests
./start.sh --help     # Show help
```

### Windows

```cmd
# Interactive menu
start.bat

# The batch script will guide you through setup and launch options
```

The startup script automatically:
- ✅ Checks Python installation
- ✅ Verifies Ollama is running (starts it if needed)
- ✅ Creates and activates virtual environment
- ✅ Installs all dependencies
- ✅ Runs diagnostic tests
- ✅ Launches your chosen interface(s)

## Manual Usage

If you prefer to run components manually:

### Terminal User Interface (TUI)

Launch the terminal-based interface:

```bash
python tui.py
```

**TUI Controls:**
- Type your message and press `Enter` to send
- Use the model selector to switch between available models
- **Ctrl+C** - Quit the application
- **Ctrl+R** - Reset conversation
- Use buttons for:
  - **New Chat** - Start a fresh conversation
  - **Clear History** - Clear current conversation
  - **Show History** - Display conversation history

### Web Interface

Launch the web-based interface:

```bash
python app.py
```

Then open your browser and navigate to:
- **Local access:** http://localhost:5000
- **Network access:** http://YOUR_IP:5000

The web interface provides:
- Real-time chat with Ollama models
- Model selection dropdown
- Conversation management
- Responsive design for desktop and mobile

## Configuration

### Environment Variables

You can create a `.env` file in the project directory for configuration:

```bash
# .env file
FLASK_HOST=0.0.0.0
FLASK_PORT=5000
FLASK_DEBUG=True
DEFAULT_MODEL=llama3
```

### Available Models

The application automatically detects all models installed in your Ollama instance. To see available models:

```bash
ollama list
```

To install a new model:

```bash
ollama pull model-name
```

## Troubleshooting

### Common Issues

1. **"No models found" or connection errors:**
   - Ensure Ollama is running: `ollama serve`
   - Check if models are installed: `ollama list`
   - Verify Ollama is accessible at default port (11434)

2. **Import errors:**
   - Make sure virtual environment is activated
   - Reinstall dependencies: `pip install -r requirements.txt`

3. **TUI not displaying properly:**
   - Ensure your terminal supports Unicode and colors
   - Try resizing the terminal window
   - Check terminal compatibility with Textual

4. **Web interface not accessible:**
   - Check firewall settings for port 5000
   - Try accessing via 127.0.0.1:5000 instead of localhost

### Debug Mode

To run in debug mode and see detailed error information:

```bash
# For TUI
python tui.py --debug

# For Web (debug is enabled by default in development)
python app.py
```

## Development

### Project Structure

```
ollama-tui/
├── start.sh            # Linux/macOS startup script
├── start.bat           # Windows startup script
├── app.py              # Flask web application
├── tui.py              # Textual TUI application  
├── tui.css             # TUI styling
├── requirements.txt    # Python dependencies
├── test_debug.py       # Diagnostic test script
├── templates/
│   └── index.html     # Web interface template
└── README.md          # This file
```

### Testing

Run the debug test script to verify all components:

```bash
python test_debug.py
```

This will test:
- Ollama connection
- Model availability
- Flask app functionality
- TUI imports and initialization

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source. Please check the LICENSE file for details.

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Ensure Ollama is properly installed and running
3. Verify all dependencies are installed correctly
4. Open an issue on GitHub with detailed error information

---

**Enjoy chatting with your local AI models!** 🤖✨
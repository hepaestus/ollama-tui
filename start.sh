#!/bin/bash

# Ollama TUI Startup Script
# This script sets up the environment and runs the necessary components

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Ollama is running
check_ollama() {
    print_status "Checking Ollama service..."
    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        print_status "✓ Ollama is running"
        return 0
    else
        print_warning "✗ Ollama is not running or not accessible"
        return 1
    fi
}

# Function to start Ollama if not running
start_ollama() {
    if ! check_ollama; then
        print_status "Attempting to start Ollama..."
        if command_exists ollama; then
            # Start Ollama in background
            if command_exists systemctl; then
                # Try systemd service first
                sudo systemctl start ollama 2>/dev/null || true
                sleep 2
            fi
            
            # If still not running, try direct command
            if ! check_ollama; then
                print_status "Starting Ollama server..."
                nohup ollama serve >/dev/null 2>&1 &
                sleep 3
            fi
            
            # Final check
            if check_ollama; then
                print_status "✓ Ollama started successfully"
            else
                print_error "✗ Failed to start Ollama"
                echo "Please start Ollama manually with: ollama serve"
                exit 1
            fi
        else
            print_error "Ollama not found. Please install Ollama first."
            echo "Visit: https://ollama.ai/"
            exit 1
        fi
    fi
}

# Function to check Python version
check_python() {
    print_status "Checking Python installation..."
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_status "✓ Python $PYTHON_VERSION found"
    else
        print_error "✗ Python 3 not found"
        exit 1
    fi
}

# Function to setup virtual environment
setup_venv() {
    print_status "Setting up Python virtual environment..."
    
    if [ ! -d ".venv" ]; then
        print_status "Creating virtual environment..."
        python3 -m venv .venv
    else
        print_status "✓ Virtual environment already exists"
    fi
    
    # Check if activate script exists, recreate venv if not
    if [ ! -f "${SCRIPT_DIR}/.venv/bin/activate" ]; then
        print_warning "Virtual environment appears corrupted, recreating..."
        rm -rf .venv
        python3 -m venv .venv
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source "${SCRIPT_DIR}/.venv/bin/activate"
    
    # Upgrade pip
    print_status "Upgrading pip..."
    pip install --upgrade pip >/dev/null 2>&1
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing Python dependencies..."
    
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
        print_status "✓ Dependencies installed from requirements.txt"
    else
        print_warning "requirements.txt not found, installing manually..."
        pip install flask textual ollama werkzeug jinja2 markupsafe itsdangerous click python-dotenv
        print_status "✓ Dependencies installed manually"
    fi
}

# Function to check Ollama models
check_models() {
    print_status "Checking available Ollama models..."
    
    # Use Python to check models since it handles the API better
    MODELS=$(python3 -c "
import ollama
try:
    response = ollama.list()
    models = []
    for model in response.models if hasattr(response, 'models') else response['models']:
        if hasattr(model, 'model'):
            models.append(model.model)
        elif isinstance(model, dict) and 'name' in model:
            models.append(model['name'])
        else:
            models.append(str(model))
    print('Models found:', len(models))
    for model in models:
        print(f'  - {model}')
except Exception as e:
    print(f'Error: {e}')
    exit(1)
" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        print_status "✓ Ollama models available:"
        echo "$MODELS"
    else
        print_warning "No models found or error checking models"
        echo "You may need to pull a model first:"
        echo "  ollama pull llama3"
        echo "  ollama pull qwen3-coder:30b"
    fi
}

# Function to run tests
run_tests() {
    print_status "Running diagnostic tests..."
    if [ -f "test_debug.py" ]; then
        python3 test_debug.py
    else
        print_warning "test_debug.py not found, skipping tests"
    fi
}

# Function to run TUI
run_tui() {
    print_header "Starting Ollama TUI"
    print_status "Launching Terminal User Interface..."
    print_status "Use Ctrl+C to quit"
    python3 tui.py
}

# Function to run Flask web app
run_web() {
    print_header "Starting Ollama Web Interface"
    print_status "Launching Flask web server..."
    print_status "Access the web interface at:"
    print_status "  Local:   http://localhost:5000"
    print_status "  Network: http://$(hostname -I | awk '{print $1}'):5000"
    print_status "Use Ctrl+C to quit"
    python3 app.py
}

# Function to run both (in background for web)
run_both() {
    print_header "Starting Both Interfaces"
    
    # Start web server in background
    print_status "Starting web server in background..."
    python3 app.py &
    WEB_PID=$!
    
    sleep 2
    print_status "Web interface available at: http://localhost:5000"
    
    # Function to cleanup background process
    cleanup() {
        print_status "Shutting down web server..."
        kill $WEB_PID 2>/dev/null || true
        exit 0
    }
    
    # Set trap to cleanup on exit
    trap cleanup EXIT INT TERM
    
    # Start TUI in foreground
    print_status "Starting TUI (use Ctrl+C to quit both)..."
    python3 tui.py
}

# Function to show menu
show_menu() {
    echo ""
    print_header "Ollama TUI Startup Menu"
    echo "Please select an option:"
    echo ""
    echo "1) Setup environment only"
    echo "2) Run Terminal UI (TUI)"
    echo "3) Run Web Interface"
    echo "4) Run Both Interfaces"
    echo "5) Run diagnostic tests"
    echo "6) Exit"
    echo ""
    read -p "Enter your choice (1-6): " choice
}

# Main setup function
setup_environment() {
    print_header "Setting Up Ollama TUI Environment"
    
    # Check prerequisites
    check_python
    start_ollama
    
    # Setup Python environment
    setup_venv
    install_dependencies
    
    # Check models and run tests
    check_models
    run_tests
    
    print_status "✓ Environment setup complete!"
}

# Parse command line arguments
case "${1:-}" in
    --setup)
        setup_environment
        exit 0
        ;;
    --tui)
        setup_environment
        run_tui
        exit 0
        ;;
    --web)
        setup_environment
        run_web
        exit 0
        ;;
    --both)
        setup_environment
        run_both
        exit 0
        ;;
    --test)
        setup_environment
        exit 0
        ;;
    --help|-h)
        echo "Ollama TUI Startup Script"
        echo ""
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  --setup    Setup environment only"
        echo "  --tui      Setup and run Terminal UI"
        echo "  --web      Setup and run Web Interface"
        echo "  --both     Setup and run both interfaces"
        echo "  --test     Setup environment and run tests"
        echo "  --help     Show this help message"
        echo ""
        echo "If no option is provided, an interactive menu will be shown."
        exit 0
        ;;
esac

# Interactive menu if no arguments provided
while true; do
    show_menu
    
    case $choice in
        1)
            setup_environment
            ;;
        2)
            setup_environment
            run_tui
            break
            ;;
        3)
            setup_environment
            run_web
            break
            ;;
        4)
            setup_environment
            run_both
            break
            ;;
        5)
            setup_environment
            break
            ;;
        6)
            print_status "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 1-6."
            ;;
    esac
done
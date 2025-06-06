# MCP Server Bootstrap: A Template for Building Modular Command Center Servers

MCP Server Bootstrap is a Python-based template for creating modular command center servers using the Mondel Context Protocol (MCP). It provides a structured foundation for building scalable command center applications with support for basic mathematical operations and modular arithmetic functions.

The project implements a modular architecture that combines individual function files into a single server core at runtime. This approach maintains code organization during development while accommodating current MCP SDK limitations regarding modularity. The template provides a foundation for building scalable command center applications with custom functionality.

## Repository Structure
```
mcp_server/                 # Main package directory
├── build_mcp.py           # Script to combine function modules into core server file
├── functions/             # Directory containing individual function implementations
│   ├── add.py            # Addition operation implementation
│   ├── product19.py      # Modulo 19 multiplication implementation
│   └── subtract.py       # Subtraction operation implementation
├── utils/                # Utility functions and helper modules
│   └── helper.py        # Common helper functions
├── pyproject.toml       # Project metadata and dependencies
├── requirements.txt     # Project dependencies
└── setup.sh            # Installation and setup script
```

## Usage Instructions
### Prerequisites
- Python 3.11 or higher
- Amazon Q CLI installed and configured
- pip package manager
- Unix-like environment (for setup.sh)

Required packages:
- fastmcp >= 1.0.0
- pydantic >= 1.10.0

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd mcp-bootstrap

# Make the setup script executable
chmod +x setup.sh

# The setup script will configure the server for use with Amazon Q CLI
# by creating necessary configuration in $HOME/.aws/amazonq/mcp.json

# Run the setup script
./setup.sh
```

### Quick Start

1. Create a new function in the `mcp_server/functions` directory:

```python
# mcp_server/functions/example.py
@mcp.tool(
    name="example",
    description="Example function"
)
def example_function(a: int, b: int) -> int:
    return a + b
```

2. Build the server:

```bash
python mcp_server/build_mcp.py
```

3. Run the server:

```bash
python mcp_server/core_combined.py
```

### Troubleshooting

Common issues and solutions:

1. **Module Not Found Errors**
   - Error: `ModuleNotFoundError: No module named 'fastmcp'`
   - Solution: Ensure you've activated the virtual environment and installed dependencies:
     ```bash
     source .venv/bin/activate
     pip install -r requirements.txt
     ```

2. **Build Failures**
   - Error: `FileNotFoundError: core_combined.py not found`
   - Solution: Run the build script from the project root:
     ```bash
     python mcp_server/build_mcp.py
     ```

3. **Version Compatibility**
   - Error: `Python version X.X is less than required 3.11`
   - Solution: Install Python 3.11 or higher and ensure it's in your PATH

## Data Flow

The MCP server processes function calls by combining individual function modules into a single core server file, which then handles incoming requests and routes them to the appropriate function implementation.

```ascii
[Client Request] -> [MCP Server Core] -> [Function Router] -> [Individual Function] -> [Response]
                                    |-> [Function Registry]
```

Component interactions:
1. The build script combines individual function files into a single core server file
2. The MCP server initializes with the combined functions
3. Client requests are received by the server core
4. Requests are routed to the appropriate function based on the tool name
5. Functions process the input and return results
6. The server core formats and sends the response back to the client
7. Error handling is managed at both the server and function levels
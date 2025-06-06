#!/usr/bin/env bash
# set -euo pipefail
set -x

# ----------------------------------------
# Shell script to set up a single MCP server project named "commandcenter",
# verify the Python version matches pyproject.toml,
# create a hidden virtual environment, install dependencies,
# and write out the Amazon Q configuration file.
# ----------------------------------------

# 1. Determine the project root (assumes this script sits in the project’s root).
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# 2. Extract the “requires-python” value from pyproject.toml (e.g., ">=3.8").
REQUIRED_PYTHON=$(grep -E '^requires-python' "$PROJECT_ROOT/pyproject.toml" \
  | sed -E 's/requires-python *= *"[>= ]*([0-9]+\.[0-9]+).*/\1/')

if [[ -z "$REQUIRED_PYTHON" ]]; then
  echo "No requires-python found in pyproject.toml. Skipping version check."
else
  # 3. Get the current Python’s major.minor (from `python3`).
  CURRENT_PYTHON=$(python3 - <<EOF
import sys
print(f"{sys.version_info.major}.{sys.version_info.minor}")
EOF
)

  # 4. Compare versions using sort -V:
  #    If the smallest of (CURRENT_PYTHON, REQUIRED_PYTHON) is REQUIRED_PYTHON,
  #    then CURRENT_PYTHON >= REQUIRED_PYTHON.
  SMALLEST=$(printf '%s\n%s' "$CURRENT_PYTHON" "$REQUIRED_PYTHON" | sort -V | head -n1)
  if [[ "$SMALLEST" != "$REQUIRED_PYTHON" ]]; then
    echo "Error: Python $CURRENT_PYTHON is less than required $REQUIRED_PYTHON (as specified in pyproject.toml)."
    exit 1
  fi
  echo "Python version $CURRENT_PYTHON meets requirement >= $REQUIRED_PYTHON."
fi

# 5. Define the hidden virtual-environment directory and update PATH.
VENV_DIR="$PROJECT_ROOT/.venv"

# 6. Create a new virtual environment.
python3 -m venv "$VENV_DIR"

# 7. Activate the virtual environment.
#    shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

# 8. Upgrade pip inside the venv and install dependencies from pyproject.toml.
pip install --upgrade pip
# Installing “.” assumes that pyproject.toml’s [project.dependencies] is respected.
pip install .

# 9. Ensure the Amazon Q config directory exists.
AWS_AMAQ_DIR="$HOME/.aws/amazonq"
mkdir -p "$AWS_AMAQ_DIR"

# 10. Write the mcp.json file that Amazon Q expects for a single server "commandcenter".
#     Use core_combined.py as the entrypoint.
cat > "$AWS_AMAQ_DIR/mcp.json" <<EOF
{
  "mcpServers": {
    "commandcenter": {
      "command": "$VENV_DIR/bin/python",
      "args": ["$PROJECT_ROOT/mcp_server/core_combined.py"]
    }
  }
}
EOF

echo "Setup complete."
echo "  Virtual environment created at: $VENV_DIR"
echo "  Amazon Q config written to: $AWS_AMAQ_DIR/mcp.json"

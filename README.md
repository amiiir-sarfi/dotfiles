My minimal zsh setup.

1. **Clone and Run:**

   ```bash
   git clone <your-repo-url>
   cd <your-repo-folder>
   chmod +x setup.sh
   ./setup.sh [--miniconda] [--cuda]
   ```

   - **`--miniconda`**: Installs Miniconda under `~/.anaconda`
   - **`--cuda`**: Detects the latest installed CUDA version and appends its path to your `.zshrc`

2. **Restart the Shell**
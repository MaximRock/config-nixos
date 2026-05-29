{
  pkgs,
  ...
}:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        mskelton.one-dark-theme
        pkief.material-icon-theme
        ms-python.python
        ms-python.vscode-pylance
        charliermarsh.ruff
        jnoortheen.nix-ide
      ];

      userSettings = {
        "explorer.confirmDelete" = false;
        "explorer.autoReveal" = false;
        "explorer.compactFolders" = false;
        "files.autoSave" = "afterDelay";
        "editor.fontSize" = 17;
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = true;
        "editor.formatOnType" = true;
        "editor.suggestOnTriggerCharacters" = true;
        "workbench.colorTheme" = "One Dark";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.editorAssociations"."*.0_x5" = "default";
        "git.autoRepositoryDetection" = "subFolders";
        "oneDark.italic" = false;
        "editor.inlineSuggest.enabled" = true;

        "llama-vscode.tool_search_source_enabled" = false;
        "llama-vscode.tool_run_terminal_command_enabled" = false;
        "llama-vscode.chat_models_list" = [
          {
            "name" = "Qwen2.5-Coder-1.5B-Instruct-Q8_0-GGUF (<= 8GB VRAM)";
            "localStartCommand" =
              "llama-server -hf ggml-org/Qwen2.5-Coder-1.5B-Instruct-Q8_0-GGUF -ngl 99 -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256 -np 2 --port 8011";
            "endpoint" = "http://127.0.0.1:8011";
          }
          {
            "name" = "Qwen3.5-9B-GGUF";
            "localStartCommand" =
              "llama-server -hf unsloth/Qwen3.5-9B-GGUF -ngl 99 -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256 -np 2 --port 8011";
            "endpoint" = "http://127.0.0.1:8011";
          }
          {
            "name" = "Qwen2.5-Coder-3B-Instruct-Q8_0-GGUF (<= 16GB VRAM)";
            "localStartCommand" =
              "llama-server -hf ggml-org/Qwen2.5-Coder-3B-Instruct-Q8_0-GGUF -ngl 99 -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256 -np 2 --port 8011";
            "endpoint" = "http://127.0.0.1:8011";
          }
          {
            "name" = "Qwen2.5-Coder-7B-Instruct-Q8_0-GGUF (> 16GB VRAM)";
            "localStartCommand" =
              "llama-server -hf ggml-org/Qwen2.5-Coder-7B-Instruct-Q8_0-GGUF -ngl 99 -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256 -np 2 --port 8011";
            "endpoint" = "http://127.0.0.1:8011";
          }
          {
            "name" = "Qwen2.5-Coder-14B-Instruct-Q8_0-GGUF (> 32GB VRAM)";
            "localStartCommand" =
              "llama-server -hf ggml-org/Qwen2.5-Coder-14B-Instruct-Q8_0-GGUF -ngl 99 -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256 -np 2 --port 8011";
            "endpoint" = "http://127.0.0.1:8011";
          }
          {
            "name" = "Qwen2.5-Coder-1.5B-Instruct-Q8_0-GGUF (CPU Only)";
            "localStartCommand" =
              "llama-server -hf ggml-org/Qwen2.5-Coder-1.5B-Instruct-Q8_0-GGUF -ub 1024 -b 1024 -dt 0.1 --ctx-size 0 --cache-reuse 256 -np 2 --port 8011";
            "endpoint" = "http://127.0.0.1:8011";
          }
          {
            "name" = "gemini qat tools";
            "localStartCommand" = "llama-server -m c:\\ai\\gemma-3-4B-it-QAT-Q4_0.gguf --port 8011";
            "endpoint" = "http://localhost:8011";
            "aiModel" = "";
            "isKeyRequired" = false;
          }
          {
            "name" = "OpenAI gpt-oss 20B";
            "localStartCommand" =
              "llama-server -hf ggml-org/gpt-oss-20b-GGUF -c 0 --jinja --reasoning-format none -np 2 --port 8011";
            "endpoint" = "http://localhost:8011";
            "aiModel" = "";
            "isKeyRequired" = false;
          }
        ];
      };
    };
  };
}

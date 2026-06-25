#!/usr/bin/env python3
"""MCP-сервер для ~/.dotfiles (NixOS + Qtile + home-manager)."""

import asyncio
import os
import subprocess
from pathlib import Path

from mcp.server import Server
from mcp.server.stdio import stdio_server


# Создаём сервер
server = Server("dotfiles-helper")


def get_repo() -> Path:
    if env := os.environ.get("DOTFILES_REPO"):
        return Path(env)
    cwd = Path.cwd()
    if (cwd / "flake.nix").exists() and (cwd / "home.nix").exists():
        return cwd
    for path in [Path.home() / ".dotfiles", Path.home() / "dotfiles"]:
        if (path / "flake.nix").exists():
            return path
    return cwd


REPO = get_repo()


@server.list_tools()
async def list_tools():
    from mcp.types import Tool, TextContent

    return [
        Tool(
            name="read_file",
            description="Читает файл по пути",
            inputSchema={
                "type": "object",
                "properties": {"path": {"type": "string"}},
                "required": ["path"],
            },
        ),
        Tool(
            name="read_flake",
            description="Читает flake.nix",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="read_home_nix",
            description="Читает home.nix",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="read_configuration",
            description="Читает configuration.nix",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="read_hardware",
            description="Читает hardware-configuration.nix",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="read_host_config",
            description="Читает hosts/nixos/default.nix",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="read_home_module",
            description="Читает модуль из home/common/ или modules/home/",
            inputSchema={
                "type": "object",
                "properties": {"module": {"type": "string"}},
                "required": ["module"],
            },
        ),
        Tool(
            name="read_nixos_module",
            description="Читает модуль из modules/nixos/",
            inputSchema={
                "type": "object",
                "properties": {"module": {"type": "string"}},
                "required": ["module"],
            },
        ),
        Tool(
            name="read_qtile_config",
            description="Читает конфиг Qtile",
            inputSchema={
                "type": "object",
                "properties": {"file": {"type": "string", "default": "default.nix"}},
            },
        ),
        Tool(
            name="read_editor_config",
            description="Читает конфиг редакторов из 11/",
            inputSchema={
                "type": "object",
                "properties": {"editor": {"type": "string"}},
                "required": ["editor"],
            },
        ),
        Tool(
            name="run_command",
            description="Выполняет shell-команду",
            inputSchema={
                "type": "object",
                "properties": {
                    "cmd": {"type": "string"},
                    "timeout": {"type": "integer", "default": 30},
                },
                "required": ["cmd"],
            },
        ),
        Tool(
            name="nix_search",
            description="Ищет пакет в nixpkgs",
            inputSchema={
                "type": "object",
                "properties": {"query": {"type": "string"}},
                "required": ["query"],
            },
        ),
        Tool(
            name="list_repo",
            description="Показывает структуру репозитория",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="git_status",
            description="Показывает git status",
            inputSchema={"type": "object", "properties": {}},
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict):
    from mcp.types import TextContent

    if name == "read_file":
        path = Path(arguments["path"]).expanduser()
        if not path.is_absolute():
            path = REPO / path
        try:
            return [TextContent(type="text", text=path.read_text())]
        except Exception as e:
            return [TextContent(type="text", text=f"Ошибка: {e}")]

    elif name == "read_flake":
        return _read_file(REPO / "flake.nix")

    elif name == "read_home_nix":
        return _read_file(REPO / "home.nix")

    elif name == "read_configuration":
        return _read_file(REPO / "configuration.nix")

    elif name == "read_hardware":
        return _read_file(REPO / "hardware-configuration.nix")

    elif name == "read_host_config":
        return _read_file(REPO / "hosts" / "nixos" / "default.nix")

    elif name == "read_home_module":
        module = arguments["module"]
        paths = [
            REPO / "home" / "common" / f"{module}.nix",
            REPO / "modules" / "home" / module / "default.nix",
        ]
        for p in paths:
            if p.exists():
                return _read_file(p)
        return [TextContent(type="text", text=f"Модуль {module} не найден")]

    elif name == "read_nixos_module":
        module = arguments["module"]
        target = REPO / "modules" / "nixos" / module / "default.nix"
        if not target.exists():
            target = REPO / "modules" / "nixos" / f"{module}.nix"
        return (
            _read_file(target)
            if target.exists()
            else [TextContent(type="text", text=f"Модуль {module} не найден")]
        )

    elif name == "read_qtile_config":
        file_name = arguments.get("file", "default.nix")
        target = REPO / "modules" / "home" / "qtile-help" / file_name
        return _read_file(target)

    elif name == "read_editor_config":
        editor = arguments["editor"]
        paths = {
            "nvim": REPO / "11" / "nvf-nvim.nix",
            "vscode": REPO / "11" / "vscode.nix",
            "aider": REPO / "11" / "aider" / "default.nix",
            "editor.nix": REPO / "11" / "editor.nix",
            "var-editors.nix": REPO / "11" / "var-editors.nix",
        }
        if editor in paths:
            return _read_file(paths[editor])
        return [TextContent(type="text", text=f"Редактор {editor} не найден")]

    elif name == "run_command":
        timeout = arguments.get("timeout", 30)
        result = subprocess.run(
            arguments["cmd"],
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=REPO,
        )
        return [TextContent(type="text", text=result.stdout + result.stderr)]

    elif name == "nix_search":
        result = subprocess.run(
            ["nix", "search", "nixpkgs", arguments["query"]],
            capture_output=True,
            text=True,
            timeout=60,
        )
        return [TextContent(type="text", text=result.stdout or result.stderr)]

    elif name == "list_repo":
        result = subprocess.run(
            ["find", str(REPO), "-maxdepth", "3", "-type", "f"],
            shell=True,
            capture_output=True,
            text=True,
        )
        files = result.stdout.strip().split("\n")
        relative = [f.replace(str(REPO) + "/", "") for f in files if f]
        return [TextContent(type="text", text="\n".join(relative))]

    elif name == "git_status":
        result = subprocess.run(
            ["git", "-C", str(REPO), "status", "--short"],
            capture_output=True,
            text=True,
        )
        return [TextContent(type="text", text=result.stdout or "Чисто")]

    return [TextContent(type="text", text=f"Неизвестный инструмент: {name}")]


def _read_file(path: Path):
    from mcp.types import TextContent

    try:
        return [TextContent(type="text", text=path.read_text())]
    except Exception as e:
        return [TextContent(type="text", text=f"Ошибка чтения {path}: {e}")]


async def _main():
    # stdio_server() без аргументов!
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream, write_stream, server.create_initialization_options()
        )


def main():
    asyncio.run(_main())


if __name__ == "__main__":
    main()

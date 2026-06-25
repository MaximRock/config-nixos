from setuptools import setup

setup(
    name="mcp-dotfiles-helper",
    version="0.1.0",
    py_modules=["server"],
    install_requires=["mcp>=1.0.0"],
    entry_points={
        "console_scripts": [
            "mcp-dotfiles-helper=server:main",
        ],
    },
)

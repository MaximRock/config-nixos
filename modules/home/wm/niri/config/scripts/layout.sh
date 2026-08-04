#!/usr/bin/env bash

layout=$(niri msg --json keyboard-layouts 2>/dev/null | jq -r '.names[.current_idx]')

case "$layout" in
    "English (US)")
        text="US"
        tooltip="English"
        ;;
    "Russian")
        text="RU"
        tooltip="Русская"
        ;;
    *)
        text="??"
        tooltip="$layout"
        ;;
esac

echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"}"

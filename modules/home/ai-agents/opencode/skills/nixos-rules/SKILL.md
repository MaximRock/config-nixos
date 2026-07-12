---
name: nixos-rules
description: Use ONLY when writing or reviewing Nix code — NixOS modules, Nix flakes, nixpkgs packages, or general Nix expressions. Covers purity/flakes, module conventions, packaging, and formatting style.
---

# Правила NixOS и Nix Flakes

## 1. Чистота и Flakes (Purity & Flakes)
- НИКОГДА не используй `<nixpkgs>` или `import <nixpkgs> {}` внутри flake-проектов. Это нечисто и устарело.
- ВСЕГДА используй Flakes (`flake.nix`). Передавай `pkgs`, `lib`, `system` и `config` явно как аргументы функции.
- Для получения исходников используй `fetchFromGitHub`, `fetchurl` и т.д. из `pkgs`. `builtins.fetchGit`/`fetchTree` допустимы с фиксированным `rev` для данных времени сборки.

## 2. Парадигма языка Nix (Nix Language Paradigm)
- Помни: Nix — это ленивый чисто функциональный язык. НЕ пиши императивную логику.
- Избегай `let ... in` для переменных, используемых только один раз, за исключением общепринятых конвенций (`cfg = config.services.*`).
- Используй функции `lib` (`lib.mapAttrs`, `lib.filter`, `lib.optionalAttrs`, `lib.mkMerge`) вместо написания собственных рекурсивных функций, когда существует стандартная функция библиотеки.
- Используй `//` для слияния attrset'ов, но предпочитай `lib.recursiveUpdate` для глубокого слияния.

## 3. Модули NixOS (NixOS Modules)
- При написании модуля NixOS функция верхнего уровня ДОЛЖНА принимать `{ config, lib, pkgs, ... }:`.
- ВСЕГДА используй `lib.mkOption` для опций. ТЫ ДОЛЖЕН указать `type` (например, `lib.types.str`, `lib.types.bool`, `lib.types.package`) и `description`.
- ВСЕГДА используй `lib.mkDefault`, `lib.mkForce` или `lib.mkOverride` при установке значений config, чтобы предотвратить конфликты при вычислении.
- Используй `lib.mkIf (config.services.myService.enable) { ... }` для условного применения конфигурации.

## 4. Пакеты и Derivation'ы (Packaging & Derivations)
- Предпочитай высокоуровневые функции сборки: `buildGoModule`, `rustPlatform.buildRustPackage`, `python3Packages.buildPythonApplication`, `stdenv.mkDerivation`.
- НИКОГДА не оставляй `hash = ""` или `sha256 = lib.fakeHash` в финальном закоммиченном коде.
- ВСЕГДА включай attrset `meta` в каждый пакет как минимум с: `description`, `homepage`, `license` (используй `lib.licenses.*`) и `maintainers`.

## 5. Форматирование и стиль (Formatting & Style)
- Код должен быть отформатирован с использованием `nixfmt` (официальный форматтер nixpkgs).
- Используй 2 пробела для отступов.
- Держи строки короче 100 символов, где это возможно.
- Используй `'' ... ''` (многострочные строки) для больших блоков текста, скриптов или конфигов, а не конкатенированные строки с `+`.

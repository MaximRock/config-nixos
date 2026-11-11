# ansible vpn-server

Роль поднимает VPS с 3x-ui (Reality+xhttp, порт 443) и настраивает клиентов.
Два режима: одиночный сервер (`inventory-single.yml`) и каскад (`inventory.yml`).

> **PRODUCTION FRANCE 45.15.128.162 — DO NOT TOUCH.**
> Не запускать Ansible/SSH, не менять конфиги/сервисы, не перезапускать.
> Только ручное включение/выключение пользователем после готовности каскада.

В secrets 12 клиентов: `max`, 10 клиентов France и `parents`. Ручной клиент
`test` есть на vpn2 и vpn3; в secrets он не входит и ролью не удаляется:
`--tags inbound` добавляет только отсутствующих.

## Файлы

| Файл | Что |
|---|---|
| `inventory.yml` | каскад: `vpn2` + `ru-relay` |
| `inventory-single.yml` | одиночный `vpn3`, без релея |
| `site.yml` | entrypoint: play `vpn_servers`, затем `relay_servers` |
| `group_vars/all/secrets.sops.yml` | секреты sops/age: пароль панели, basePath, private key, uuid/subId |
| `roles/vpn-server/` | harden → 3x-ui → remark → inbound → links |
| `roles/vpn-relay/` | harden → HAProxy TCP passthrough |

## Подготовка

Все команды — из корня репозитория: `cd ~/.dotfiles`. Ansible запускается через nix:

```sh
nix shell nixpkgs#ansible -c ansible-playbook ...
```

Секреты sops расшифровываются автоматически, если запускать из корня репозитория.
Для нового VPS ключ с ноутбука должен быть у root:

```sh
ssh-copy-id -p 22 root@<IP>
```

Проверить состав хостов и синтаксис:

```sh
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml --list-hosts
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml --syntax-check
```

## vpn3 — одиночный сервер (GB)

`inventory-single.yml`: vpn3 `88.218.93.5`, без релея.
Ссылки — `~/Documents/proxy/vpn3-links.txt`.

### Без правки файлов (`-e`)

Текущий/финальный прогон:

```sh
cd ~/.dotfiles
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory-single.yml ansible/site.yml
```

Первый прогон нового VPS (22 ещё открыт):

```sh
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory-single.yml ansible/site.yml \
  -e ansible_port=22 -e ssh_keep_old_port=true
```

После успеха повторить финальную команду без `-e`: она закроет 22 и оставит `43909`.

### С правкой файлов

`ansible/inventory-single.yml`:

| Переменная | Сейчас | Когда менять |
|---|---|---|
| `ansible_host` | `88.218.93.5` | новый IP |
| `ansible_port` | `43909` | рабочий SSH-порт; первый прогон нового VPS — `22` |
| `ssh_port` | `43909` | финальный SSH-порт |
| `ssh_keep_old_port` | `false` | `true` только на первом прогоне |
| `country_code` | `gb` | метка страны в ссылках |
| `inbound_remark` | `gb-reality-xhttp-443` | имя инбаунда и префикс в QR панели |

Первый прогон: `ansible_port: 22`, `ssh_keep_old_port: true`; после — `43909`/`false`
и повторный запуск. Новый IP меняется здесь же: от него зависят ссылки, `shareAddr`
и панель.

## Каскад — vpn2 + RU-релей

Клиент → RU `62.173.152.18:443` → vpn2 `138.124.84.121:443`.
HAProxy работает в `mode tcp` без терминации TLS: Reality идёт end-to-end, ключи
и панель остаются только на vpn2. Ссылки: `vpn2-links.txt` и `relay-links.txt`.

### Без правки файлов (`-e`)

Текущий полный каскад (vpn2, затем релей):

```sh
cd ~/.dotfiles
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml
```

Первый прогон нового vpn2:

```sh
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml \
  --limit vpn2 -e ansible_port=22 -e ssh_keep_old_port=true
```

Первый прогон нового релея:

```sh
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml \
  --limit relay_servers -e ansible_port=22 -e ssh_keep_old_port=true
```

Ссылки через релей (генерируются на vpn2, меняется адрес и метка страны):

```sh
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml \
  --limit vpn2 --tags links \
  -e link_host=62.173.152.18 -e link_port=443 -e country_code=ru \
  -e links_file_name=relay-links.txt
```

`-e` действует на все хосты плейбука. На каскадном inventory всегда добавляй
`--limit vpn2` или `--limit relay_servers`, иначе переменная попадёт и на второй сервер.

### С правкой файлов

`ansible/inventory.yml`, блок `vpn2`:

| Переменная | Сейчас | Когда менять |
|---|---|---|
| `ansible_host` | `138.124.84.121` | новый IP |
| `ansible_port` | `57777` | рабочий SSH-порт; первый прогон — `22` |
| `ssh_keep_old_port` | `false` | `true` только на первом прогоне |
| `country_code` | `se` | метка страны в ссылках |
| `inbound_remark` | `se-reality-xhttp-443` | имя инбаунда и префикс в QR панели |
| `fail2ban_ignore_ips` | `['62.173.152.18']` | IP релея |

`ssh_port` для vpn2 не задан — берётся default `57777`; менять только если нужен другой порт.

`inbound_remark` должен начинаться с двухбуквенного кода страны (`se-`, `gb-`):
helper заменяет этот префикс на `country_code` при генерации ссылок. На живом
сервере remark меняется только через `--tags links` или `--tags inbound` —
remark-фаза идёт до создания/проверки инбаунда.

Блок `ru-relay`:

| Переменная | Сейчас | Когда менять |
|---|---|---|
| `ansible_host` | `62.173.152.18` | новый IP релея |
| `ansible_port` | `57777` | рабочий SSH-порт; первый прогон — `22` |
| `ssh_port` | `57777` | финальный SSH-порт |
| `ssh_keep_old_port` | `false` | `true` только на первом прогоне |
| `relay_backends` | `[{name: se, host: 138.124.84.121, port: 443}]` | IP/порт vpn2 |

France в inventory остаётся закомментированным. Новый IP и `relay_backends`
меняются только здесь: от них зависят ссылки, `shareAddr` и маршрут релея.

### Проверка релея

```sh
echo | openssl s_client -connect 62.173.152.18:443 -servername www.samsung.com 2>/dev/null | openssl x509 -noout -subject
curl -sk https://62.173.152.18/ -H 'Host: www.samsung.com' -o /dev/null -w '%{http_code}\n'
```

Если 443 не отвечает (SYN-proxy хостера) — сменить `relay_listen_port` на 8443
и перегенерировать ссылки с `link_port=8443`.

## Запуск отдельно каждого сервера

| Задача | Команда |
|---|---|
| только vpn2 | `... -i ansible/inventory.yml ansible/site.yml --limit vpn2` |
| только vpn3 | `... -i ansible/inventory-single.yml ansible/site.yml --limit vpn3` |
| только релей | `... -i ansible/inventory.yml ansible/site.yml --limit ru-relay` |
| ссылки vpn2 | `... -i ansible/inventory.yml ansible/site.yml --limit vpn2 --tags links` |
| ссылки vpn3 | `... -i ansible/inventory-single.yml ansible/site.yml --limit vpn3 --tags links` |
| ссылки через релей | команда из раздела каскада (`link_host`, `country_code=ru`, `relay-links.txt`) |

`...` — это `nix shell nixpkgs#ansible -c ansible-playbook`.
`--limit` принимает хост (`vpn2`) или группу (`vpn_servers`, `relay_servers`).

## Sops — секреты

Посмотреть (ничего не меняет):

```sh
cd ~/.dotfiles
sops -d ansible/group_vars/all/secrets.sops.yml
```

Изменить:

```sh
sops ansible/group_vars/all/secrets.sops.yml
```

| Ключ | Что |
|---|---|
| `panel_password` | пароль панели, логин `admin` |
| `panel_basepath` | хвост URL панели |
| `reality_private_key` | ключ Reality, не трогать |
| `clients` | uuid/subId клиентов |

Добавить клиента: дописать в `clients` и сгенерировать uuid:

```yaml
clients:
  - email: max
    uuid: <uuid max>
    subId: <subId max>
  - email: phone
    uuid: <uuidgen>
    subId: <любая уникальная строка>
```

```sh
uuidgen
```

Применить на vpn2:

```sh
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml \
  --limit vpn2 --tags inbound
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml \
  --limit vpn2 --tags links
nix shell nixpkgs#ansible -c ansible-playbook -i ansible/inventory.yml ansible/site.yml \
  --limit vpn2 --tags links -e link_host=62.173.152.18 -e link_port=443 \
  -e country_code=ru -e links_file_name=relay-links.txt
```

На vpn3 — та же пара `inbound`/`links` с `-i ansible/inventory-single.yml`.
`test` в secrets не входит; `--tags inbound` его не удаляет.

## Теги

| Тег | Роль | Что делает |
|---|---|---|
| `harden` | vpn-server, relay | SSH-порт, UFW, fail2ban |
| `xui` | vpn-server | установка/настройка 3x-ui, панель, сервис |
| `inbound` | vpn-server | remark, inbound, добавление отсутствующих клиентов, asserts |
| `links` | vpn-server | remark и генерация файла ссылок (при смене remark — краткий restart x-ui) |
| `relay` | relay | конфиг HAProxy и сервис |

Без тегов — полный прогон. Теги можно объединять: `--tags xui,inbound`.

```sh
# только ссылки vpn2
... --limit vpn2 --tags links

# только ссылки через релей
... --limit vpn2 --tags links -e link_host=62.173.152.18 -e link_port=443 \
  -e country_code=ru -e links_file_name=relay-links.txt

# добавить клиентов из secrets
... --limit vpn2 --tags inbound

# после правки пароля/панели в secrets
... --limit vpn2 --tags xui,inbound

# только HAProxy
... --limit ru-relay --tags relay

# только SSH/UFW/fail2ban на релее
... --limit ru-relay --tags harden
```

- `--tags links` копирует helper и конфиг, синхронизирует remark (при смене —
  краткий restart x-ui) и генерирует ссылки.
- `--tags inbound` не удаляет ручного `test`; remark-фаза выполняется до inbound.
- `-e xui_recreate_inbound=true` пересоздаёт inbound и удалит `test` — только осознанно.
- `--check` показывает предпросмотр, но `command`-задачи могут пропускаться или вести себя иначе.
- При `-e` на каскадном inventory не забывай `--limit`.

## Доступ к панели и проверки

| Сервер | SSH | Панель |
|---|---|---|
| vpn2 | `ssh -p 57777 root@138.124.84.121` | туннель ниже |
| vpn3 | `ssh -p 43909 root@88.218.93.5` | туннель ниже |
| ru-relay | `ssh -p 57777 root@62.173.152.18` | нет панели |

Панель 3x-ui — только через SSH-туннель (команду держать висящей):

```sh
ssh -L 8080:127.0.0.1:42182 -p 57777 root@138.124.84.121
```

Для vpn3 заменить порт и IP: `-p 43909 root@88.218.93.5`. Затем открыть
`http://localhost:8080<panel_basepath>`; логин `admin`, пароль `panel_password`
из secrets. QR — кнопка у клиента в панели.

Страна в имени ссылки задаётся `country_code`: `se-reality-xhttp-443-max` (vpn2),
`ru-...` (релей), `gb-...` (vpn3). QR в панели берёт имя из `inbound_remark`,
поэтому после смены remark он тоже получает префикс. Уже импортированные
профили Throne не переименовываются — их нужно переимпортировать.

Роль проверяет uuid/security/subId в БД, `shareAddr`, `encryption=none` в ссылках
и маску 443 (сертификат SNI-таргета). `fp=firefox` — chrome заблокирован ТСПУ;
менять в `roles/vpn-server/defaults/main.yml → reality_fingerprint`.

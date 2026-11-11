#!/usr/bin/env python3
"""3x-ui provisioning helper for the vpn-server ansible role.

Usage: xui_api.py <configure|inbound|recreate|remark|links>  ; config at /tmp/xui_vars.json

configure: panel port/basepath/listen/subEnable + admin creds (idempotent).
inbound:   create inbound if missing, fix clients table uuids, set share
           address, restart, end-to-end link asserts.
recreate:  delete inbound with same remark, then create it with current
           clients (use after adding/removing clients in secrets).
remark:    sync inbound remark by port (country prefix in panel QR).
links:     canonical panel links per client -> /tmp/xui_links.txt,
           rewriting host/port to link_host/link_port and replacing the
           server country prefix with country_code (relay).
"""
import http.cookiejar
import json
import re
import sqlite3
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, NoReturn

try:
    import bcrypt  # type: ignore[import-not-found]  # ставится ansible'ом (python3-bcrypt)
except ImportError:
    bcrypt = None  # configure без него упадёт с понятной ошибкой

DB = "/etc/x-ui/x-ui.db"


def fail(msg: str) -> NoReturn:
    print("FAIL: " + msg)
    sys.exit(1)


def load_cfg(path):
    with open(path, "r", encoding="utf-8") as f:
        cfg = json.load(f)

    def check(obj, where):
        if isinstance(obj, str) and obj.startswith("ENC["):
            fail("секрет не расшифрован ({0}): запустите прогон В КОРНЕ репозитория (.dotfiles) — оттуда подхватывается ansible.cfg и sops-плагин".format(where))
        if isinstance(obj, dict):
            for k, v in obj.items():
                check(v, "{0}.{1}".format(where, k))
        if isinstance(obj, list):
            for i, v in enumerate(obj):
                check(v, "{0}[{1}]".format(where, i))

    check(cfg, "cfg")
    return cfg


class Api:
    def __init__(self, port, basepath, user, password):
        self.base = "http://127.0.0.1:{0}{1}".format(port, basepath)
        self.user = user
        self.password = password
        self.cookies = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(self.cookies)
        )
        self.token = None

    def request(self, path, data=None, form=False):
        headers = {}
        body = None
        if data is not None:
            body = urllib.parse.urlencode(data).encode() if form else json.dumps(data).encode()
            headers["Content-Type"] = (
                "application/x-www-form-urlencoded" if form else "application/json"
            )
        if self.token:
            headers["X-CSRF-Token"] = self.token
        # basepath ends with '/': strip leading '/' to avoid '//' (gin returns 404+empty)
        req = urllib.request.Request(self.base + path.lstrip("/"), data=body, headers=headers)
        try:
            resp = self.opener.open(req, timeout=25)
        except urllib.error.HTTPError as e:
            resp = e
        return resp.status, resp.read().decode("utf-8", "replace")

    def fetch_csrf(self):
        st, html = self.request("/")
        m = re.search(r'csrf-token" content="([^"]+)"', html)
        if not m:
            fail("no csrf meta (status {0}); wrong port/basepath?".format(st))
        self.token = m.group(1)

    def login(self):
        self.fetch_csrf()
        st, txt = 0, ""
        for _ in range(2):
            st, txt = self.request(
                "/login",
                {"username": self.user, "password": self.password},
                form=True,
            )
            if '"success":true' in txt:
                return
            self.fetch_csrf()
        fail("login failed: " + txt[:200])

    def api(self, path, data=None) -> Any:
        st, txt = 0, ""
        for _ in range(2):
            # data=None => GET (read endpoints are GET-only; empty dict forced POST => gin 404 empty)
            st, txt = self.request("/panel/api" + path, data=data)
            try:
                j = json.loads(txt)
            except ValueError:
                j = None
            if j is not None and j.get("success"):
                return j["obj"]
            self.fetch_csrf()
        fail("api {0} failed (status {1}): {2}".format(path, st, txt[:200]))


def upsert_setting(con, key, value):
    row = con.execute("SELECT value FROM settings WHERE key=?", (key,)).fetchone()
    if row is None:
        con.execute("INSERT INTO settings(key, value) VALUES(?, ?)", (key, value))
    else:
        con.execute("UPDATE settings SET value=? WHERE key=?", (value, key))


def configure(cfg):
    if bcrypt is None:  # локальный LSP-шум: пакет ставится ansible'ом на сервере
        fail("python3-bcrypt не установлен (должен ставить ansible)")
    try:
        con = sqlite3.connect(DB)
    except sqlite3.OperationalError:
        fail("cannot open {0}; is x-ui installed?".format(DB))
    con.row_factory = sqlite3.Row  # configure uses dict-style access below
    cur = {k: v for k, v in con.execute("SELECT key, value FROM settings")}
    user = con.execute("SELECT username, password FROM users").fetchone()
    if user is None:
        fail("users table empty")
    wanted = {
        "webPort": str(cfg["panel_port"]),
        "webBasePath": cfg["panel_basepath"],
        "webListenAddress": "127.0.0.1",
        "subEnable": "false",
    }
    try:
        pw = user["password"]
        if isinstance(pw, str):
            pw = pw.encode()
        ok_pass = bcrypt.checkpw(cfg["panel_password"].encode(), pw)
    except ValueError:
        ok_pass = False
    if (
        user["username"] == cfg["panel_user"]
        and ok_pass
        and all(cur.get(k) == v for k, v in wanted.items())
    ):
        print("configure: ok (unchanged)")
        return
    changed = [k for k, v in wanted.items() if cur.get(k) != v]
    for k, v in wanted.items():
        upsert_setting(con, k, v)
    con.execute(
        "UPDATE users SET username=?, password=?",
        (cfg["panel_user"], bcrypt.hashpw(cfg["panel_password"].encode(), bcrypt.gensalt(10))),
    )
    con.commit()
    con.close()
    subprocess.run(["systemctl", "restart", "x-ui"], check=False)  # repair path: broken settings may make restart fail; systemd autostart picks up fixed sqlite
    time.sleep(4)
    url = "http://127.0.0.1:{0}{1}".format(cfg["panel_port"], cfg["panel_basepath"])
    last = None
    for _ in range(4):
        try:
            urllib.request.urlopen(url, timeout=6)
            break
        except urllib.error.HTTPError:
            break  # HTTP response means panel is up
        except Exception as e:
            last = e
            time.sleep(2)
    else:
        print("configure: panel not reachable yet ({0}); will rely on service start/autostart".format(last))
    if not ok_pass:
        changed.append("password")
    print("configure: changed: " + ", ".join(sorted(set(changed))))


def client_obj(c):
    return {
        "id": c["uuid"],
        "email": c["email"],
        "security": "",
        "subId": c["subId"],
        "limitIp": 0,
        "totalGB": 0,
        "expiryTime": 0,
        "enable": True,
        "tgId": 0,
        "reset": 0,
        "resetDay": 0,
        "resetMax": 0,
        "resetWeekday": 0,
        "trafficReset": "never",
        "trafficResetDay": 1,
        "keepAlive": 0,
        "comment": "",
    }


def build_inbound(cfg):
    clients = [client_obj(c) for c in cfg["clients"]]
    stream = {
        "network": "xhttp",
        "xhttpSettings": {
            "path": cfg["xhttp_path"],
            "host": "",
            "mode": "packet-up",
            "xPaddingBytes": "100-1000",
            "scMaxBufferedPosts": 30,
        },
        "security": "reality",
        "realitySettings": {
            "show": False,
            "xver": 0,
            "target": cfg["sni_target"] + ":443",
            "serverNames": [cfg["sni_target"]],
            "privateKey": cfg["reality_private_key"],
            "minClientVer": "",
            "maxClientVer": "",
            "maxTimediff": 0,
            "shortIds": cfg["reality_short_ids"],
            "mldsa65Seed": "",
            "settings": {
                "publicKey": cfg["reality_public_key"],
                "fingerprint": cfg["reality_fingerprint"],
                "serverName": "",
                "spiderX": cfg["spider_x"],
                "mldsa65Verify": "",
            },
        },
    }
    sniffing = {"enabled": True, "destOverride": ["http", "tls", "quic"], "metadataOnly": False, "routeOnly": False}
    return {
        "id": 1,
        "enable": True,
        "remark": cfg["inbound_remark"],
        "port": cfg["inbound_port"],
        "protocol": "vless",
        "settings": json.dumps(
            {"clients": clients, "decryption": "none", "fallbacks": []}
        ),
        "streamSettings": json.dumps(stream),
        "sniffing": json.dumps(sniffing),
        "shareAddrStrategy": "custom",
        "shareAddr": cfg["server_ip"],
    }


def fix_clients_table(cfg, con, inbound_id):
    sttxt = con.execute(
        "SELECT settings FROM inbounds WHERE id=?", (inbound_id,)
    ).fetchone()[0]
    s = json.loads(sttxt)
    rows = con.execute(
        "SELECT cl.id, cl.email, cl.uuid, cl.security, cl.sub_id FROM clients cl "
        "JOIN client_inbounds ci ON ci.client_id = cl.id WHERE ci.inbound_id=?",
        (inbound_id,),
    ).fetchall()
    by_email = {r["email"]: r for r in rows}
    fixed = []
    for cl in s.get("clients", []):
        row = by_email.get(cl["email"])
        if row is None:
            fail("client not in clients table: " + cl["email"])
        if row["uuid"] != cl["id"]:
            con.execute("UPDATE clients SET uuid=? WHERE id=?", (cl["id"], row["id"]))
            fixed.append(cl["email"] + ":uuid")
        if row["security"] not in (None, ""):
            # security="auto" ломает сгенерированные ссылки (encryption=auto)
            con.execute("UPDATE clients SET security='' WHERE id=?", (row["id"],))
            fixed.append(cl["email"] + ":security")
        if row["sub_id"] != (cl.get("subId") or ""):
            con.execute(
                "UPDATE clients SET sub_id=? WHERE id=?",
                (cl.get("subId") or "", row["id"]),
            )
            fixed.append(cl["email"] + ":subId")
    con.commit()
    return fixed


def fix_share_addr(cfg, con, inbound_id):
    row = con.execute(
        "SELECT share_addr_strategy, share_addr FROM inbounds WHERE id=?",
        (inbound_id,),
    ).fetchone()
    if row and row[0] == "custom" and row[1] == cfg["server_ip"]:
        return False
    con.execute(
        "UPDATE inbounds SET share_addr_strategy='custom', share_addr=? WHERE id=?",
        (cfg["server_ip"], inbound_id),
    )
    con.commit()
    return True


def remark(cfg):
    con = sqlite3.connect(DB)
    rows = con.execute(
        "SELECT id, remark FROM inbounds WHERE port=?", (cfg["inbound_port"],)
    ).fetchall()
    if not rows:
        con.close()
        print("remark: no inbound on port {0} (will be created)".format(cfg["inbound_port"]))
        return
    if len(rows) > 1:
        con.close()
        fail(
            "multiple inbounds on port {0}: {1}".format(
                cfg["inbound_port"], [r[0] for r in rows]
            )
        )
    inbound_id, current = rows[0]
    if current == cfg["inbound_remark"]:
        con.close()
        print("remark: ok (unchanged)")
        return
    con.execute(
        "UPDATE inbounds SET remark=? WHERE id=?", (cfg["inbound_remark"], inbound_id)
    )
    con.commit()
    con.close()
    subprocess.run(["systemctl", "restart", "x-ui"], check=True)
    time.sleep(4)
    print("remark: changed: {0} -> {1}".format(current, cfg["inbound_remark"]))


def add_missing_clients(cfg, api, inbound_id, obj):
    settings = obj.get("settings") or {}
    if isinstance(settings, str):
        settings = json.loads(settings)
    existing = {c.get("email") for c in settings.get("clients", [])}
    added = []
    for c in cfg["clients"]:
        if c["email"] in existing:
            continue
        api.api(
            "/clients/add",
            {"client": client_obj(c), "inboundIds": [inbound_id]},
        )
        added.append(c["email"])
    return added


def inbound(cfg, recreate=False):
    api = Api(cfg["panel_port"], cfg["panel_basepath"], cfg["panel_user"], cfg["panel_password"])
    api.login()
    listing = api.api("/inbounds/list") or []
    found = [i for i in listing if i.get("remark") == cfg["inbound_remark"]]
    if not found:
        same_port = [
            i for i in listing if str(i.get("port")) == str(cfg["inbound_port"])
        ]
        if same_port:
            fail(
                "inbound on port {0} has remark '{1}', expected '{2}'; "
                "run --tags links (remark phase) or fix inventory".format(
                    cfg["inbound_port"],
                    same_port[0].get("remark"),
                    cfg["inbound_remark"],
                )
            )
    if found and recreate:
        api.api("/inbounds/del/{0}".format(found[0]["id"]), data={})
        print("inbound: deleted (id {0})".format(found[0]["id"]))
        found = []
    if found:
        inbound_id = found[0]["id"]
        print("inbound: exists (id {0})".format(inbound_id))
        obj = api.api("/inbounds/get/{0}".format(inbound_id))
        added = add_missing_clients(cfg, api, inbound_id, obj)
        if added:
            print("inbound: fixed: " + ", ".join(e + ":added" for e in added))
    else:
        obj = api.api("/inbounds/add", build_inbound(cfg))
        inbound_id = obj["id"]
        print("inbound: created (id {0})".format(inbound_id))
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    changed = fix_clients_table(cfg, con, inbound_id)
    if fix_share_addr(cfg, con, inbound_id):
        changed.append("shareAddr")
    con.close()
    if changed:
        print("inbound: fixed: " + ", ".join(changed))
        subprocess.run(["systemctl", "restart", "x-ui"], check=True)
        time.sleep(4)
    subprocess.run(["x-ui", "restart-xray"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(4)
    check = Api(cfg["panel_port"], cfg["panel_basepath"], cfg["panel_user"], cfg["panel_password"])
    check.login()
    for c in cfg["clients"]:
        links = check.api("/clients/links/{0}".format(c["email"])) or []
        joined = "\n".join(links)
        marker = "vless://{0}@{1}".format(c["uuid"], cfg["server_ip"])
        if marker not in joined or "encryption=none" not in joined:
            fail(
                "link assert for {0}: expected {1}; got {2}".format(
                    c["email"], marker, (links[:1] or ["<none>"])[0][:180]
                )
            )
    print("inbound: links verified for " + ", ".join(c["email"] for c in cfg["clients"]))


def rewrite_link(link, host, port, country="", server_country=""):
    prefix, rest = link.split("@", 1)
    _, sep, tail = rest.partition("?")
    out = "{0}@{1}:{2}{3}{4}".format(prefix, host, port, sep, tail)
    if country:
        base, hash_sep, frag = out.partition("#")
        if hash_sep:
            if server_country and frag.startswith(server_country + "-"):
                frag = frag[len(server_country) + 1:]
            out = base + hash_sep + country + "-" + frag
    return out


def links(cfg):
    api = Api(cfg["panel_port"], cfg["panel_basepath"], cfg["panel_user"], cfg["panel_password"])
    api.login()
    host = cfg.get("link_host") or cfg["server_ip"]
    port = cfg.get("link_port") or cfg["inbound_port"]
    country = cfg.get("country_code") or ""
    server_country = (cfg.get("inbound_remark") or "").split("-", 1)[0]
    if len(server_country) != 2 or not server_country.isalpha() or not server_country.islower():
        server_country = ""
    out = []
    for c in cfg["clients"]:
        links = api.api("/clients/links/{0}".format(c["email"])) or []
        out.extend(
            rewrite_link(x, host, port, country, server_country)
            for x in links
            if x.startswith("vless://")
        )
    with open("/tmp/xui_links.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")
    print("links: wrote {0} entries".format(len(out)))


def main():
    phases = {
        "configure": configure,
        "inbound": inbound,
        "recreate": lambda cfg: inbound(cfg, True),
        "remark": remark,
        "links": links,
    }
    if len(sys.argv) != 2 or sys.argv[1] not in phases:
        fail("usage: xui_api.py <configure|inbound|recreate|remark|links> ; config /tmp/xui_vars.json")
    cfg = load_cfg("/tmp/xui_vars.json")
    phases[sys.argv[1]](cfg)


if __name__ == "__main__":
    main()

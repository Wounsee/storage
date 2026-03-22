import random
import time
import threading
import sys
import string
from datetime import datetime
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.layout import Layout
from rich.live import Live
from rich.text import Text
from rich.align import Align
from rich.box import HEAVY, ROUNDED, DOUBLE, SIMPLE_HEAVY
from rich.progress import Progress, SpinnerColumn, BarColumn, TextColumn, TimeElapsedColumn
from rich.prompt import Prompt

console = Console()


def uid():
    s = lambda n: ''.join(random.choices('0123456789abcdef', k=n))
    return f"{s(8)}-{s(4)}-{s(4)}-{s(4)}-{s(12)}"

def fake_ip():
    return f"{random.randint(1,254)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}"

def fake_proxy():
    t = random.choice(["SOCKS5","SOCKS4","HTTP","HTTPS","SOCKS5h"])
    return f"{t}://{fake_ip()}:{random.choice([1080,3128,8080,8888,9050,9150,4145,443,80,1081,8443,3129])}"

def fake_latency():
    return round(random.uniform(4, 940), 1)

def format_bytes(b):
    for u in ["B","KB","MB","GB","TB"]:
        if b < 1024: return f"{b:.1f} {u}"
        b /= 1024
    return f"{b:.1f} PB"

def desktop_name():
    return "DESKTOP-" + ''.join(random.choices(string.ascii_uppercase + string.digits, k=7))

def server_name():
    p = random.choice(["SRV","NODE","VPS","CLOUD","WORKER","RELAY","PROXY","GATE","DC","HOST","VM"])
    return p + "-" + ''.join(random.choices(string.ascii_uppercase + string.digits, k=random.choice([5,6,7])))

def linux_hostname():
    adj = random.choice([
        "dark","silent","void","null","phantom","shadow","ghost","stealth","acid","neon",
        "cyber","frost","blaze","iron","cobalt","carbon","oxide","zinc","onyx","quartz",
        "pulse","venom","storm","nexus","helix","nova","orion","flux","apex","omega",
        "hydra","titan","argon","xenon","nyx","arc","ion","zero","hex","rust",
    ])
    noun = random.choice([
        "box","node","core","link","hub","gate","mesh","grid","net","stack",
        "shell","root","daemon","kernel","stream","relay","proxy","cache","vault","mirror",
        "pod","shard","cell","drone","agent","probe","beacon","forge","blade","wire",
    ])
    return f"{adj}-{noun}-{random.randint(1,9999):04d}"

WINDOWS = [
    "Windows 11 Pro 23H2","Windows 11 Enterprise 23H2","Windows 11 Home 23H2",
    "Windows 11 Pro 24H2","Windows 11 Education 23H2",
    "Windows 10 Pro 22H2","Windows 10 LTSC 2021","Windows 10 Enterprise 22H2",
    "Windows 10 Home 22H2","Windows 10 IoT Enterprise LTSC",
    "Windows Server 2022 Datacenter","Windows Server 2022 Standard",
    "Windows Server 2019 Standard","Windows Server 2019 Datacenter",
    "Windows Server 2016 Standard",
]

LINUX = [
    ("Ubuntu 22.04.4 LTS","Jammy"),("Ubuntu 24.04 LTS","Noble"),("Ubuntu 20.04.6 LTS","Focal"),
    ("Ubuntu 23.10","Mantic"),("Ubuntu Server 22.04","Jammy"),
    ("Debian 12.6","Bookworm"),("Debian 11.10","Bullseye"),("Debian 10.13","Buster"),
    ("Kali Linux 2024.2","kali-rolling"),("Kali Linux 2024.1","kali-rolling"),
    ("Arch Linux 2024.06","rolling"),("Arch Linux 2024.07","rolling"),
    ("Fedora 40 Workstation","Forty"),("Fedora 40 Server","Forty"),("Fedora 39","ThirtyNine"),
    ("CentOS Stream 9","Plow"),("CentOS Stream 8",""),
    ("Rocky Linux 9.4","Blue Onyx"),("Rocky Linux 8.10","Green Obsidian"),
    ("AlmaLinux 9.4","Seafoam Ocelot"),("AlmaLinux 8.10","Cerulean Leopard"),
    ("ParrotOS 6.1 Security","lorikeet"),("ParrotOS 6.0 Home","lorikeet"),
    ("BlackArch Linux 2024.04","rolling"),
    ("Manjaro 24.0","stable"),("Manjaro 23.1","stable"),
    ("openSUSE Leap 15.6","stable"),("openSUSE Tumbleweed","rolling"),
    ("Alpine Linux 3.20","stable"),("Alpine Linux 3.19","stable"),
    ("Void Linux glibc","rolling"),("Void Linux musl","rolling"),
    ("Gentoo Linux","rolling"),("Gentoo Hardened","rolling"),
    ("Linux Mint 21.3","Virginia"),("Linux Mint 22","Wilma"),
    ("Pop!_OS 22.04 LTS","jammy"),("Pop!_OS 24.04","noble"),
    ("EndeavourOS Gemini","rolling"),("EndeavourOS Galileo","rolling"),
    ("Garuda Linux dr460nized","rolling"),
    ("Tails 6.4","stable"),("Whonix 17","bookworm"),("Qubes OS 4.2","stable"),
    ("NixOS 24.05","Uakari"),("NixOS 23.11","Tapir"),
    ("Slackware 15.0","stable"),("MX Linux 23.2","Libretto"),
    ("Zorin OS 17.1 Pro","jammy"),("Elementary OS 7.1","Horus"),
    ("Deepin 23","stable"),("Solus 4.5","Resilience"),
    ("Clear Linux","rolling"),("Puppy Linux 10","Scarthgap"),
]

REGIONS = [
    "Франкфурт, DE","Нью-Йорк, US","Лос-Анджелес, US","Даллас, US","Чикаго, US",
    "Майами, US","Сиэтл, US","Вашингтон, US","Атланта, US","Денвер, US",
    "Лондон, GB","Париж, FR","Амстердам, NL","Стокгольм, SE","Хельсинки, FI",
    "Цюрих, CH","Вена, AT","Варшава, PL","Бухарест, RO","Прага, CZ",
    "Мадрид, ES","Милан, IT","Дублин, IE","Осло, NO","Копенгаген, DK",
    "Берлин, DE","Мюнхен, DE","Лиссабон, PT","Братислава, SK","Будапешт, HU",
    "Токио, JP","Сеул, KR","Сингапур, SG","Мумбаи, IN","Джакарта, ID",
    "Сидней, AU","Мельбурн, AU","Бангкок, TH","Манила, PH","Ханой, VN",
    "Осака, JP","Бангалор, IN","Гонконг, HK","Тайбэй, TW",
    "Сан-Паулу, BR","Буэнос-Айрес, AR","Сантьяго, CL","Богота, CO","Лима, PE",
    "Торонто, CA","Монреаль, CA","Ванкувер, CA","Мехико, MX",
    "Йоханнесбург, ZA","Кейптаун, ZA","Дубай, AE","Стамбул, TR",
    "Москва, RU","Киев, UA","Рига, LV","Таллин, EE","Вильнюс, LT",
]

KERNELS_WIN = ["NT 10.0.19045","NT 10.0.22631","NT 10.0.22621","NT 10.0.20348","NT 10.0.26100","NT 10.0.17763"]
KERNELS_LIN_VER = ["5.4","5.10","5.15","6.1","6.5","6.6","6.8","6.9","6.10"]
KERNELS_LIN_SFX = ["generic","amd64","cloud","lts","zen","hardened","rt","lowlatency","xanmod","cachyos"]
ARCHES = ["x86_64"]*8 + ["arm64","aarch64"]


def gen_device():
    is_win = random.random() < 0.30
    if is_win:
        hostname = desktop_name() if random.random() < 0.65 else server_name()
        os_name = random.choice(WINDOWS)
        kernel = random.choice(KERNELS_WIN)
    else:
        hostname = linux_hostname() if random.random() < 0.7 else server_name()
        d = random.choice(LINUX)
        os_name = d[0]
        kernel = f"{random.choice(KERNELS_LIN_VER)}.{random.randint(0,199)}-{random.choice(KERNELS_LIN_SFX)}"
    return {
        "hostname": hostname, "uuid": uid(), "os": os_name, "kernel": kernel,
        "arch": random.choice(ARCHES), "region": random.choice(REGIONS),
        "proxy": fake_proxy(), "ip": fake_ip(),
        "latency": fake_latency(), "is_win": is_win,
    }


METHODS = ["GET","POST","HEAD","PUT","OPTIONS","PATCH","DELETE"]
STATUSES = [200]*35+[201]*5+[301]*3+[302]*2+[403]*3+[408]*2+[429]*5+[500]*2+[502]*3+[503]*4+[504]*2
UA_SHORT = ["Chrome/126","Firefox/128","Edge/126","curl/8.7","requests/2.32","Go-http/2.0","Wget/1.24","httpx/0.27","okhttp/4.12"]
PATHS = ["/","/index","/api/v1/data","/login","/search","/assets/app.js","/favicon.ico","/wp-admin","/xmlrpc.php","/.env","/api/health","/graphql","/feed","/sitemap.xml","/robots.txt","/admin","/dashboard","/upload","/cdn/img","/ws"]
MAX_LOGS = 24

stats = {
    "reqs":0,"ok":0,"fail":0,"bytes":0,
    "t0":None,"running":False,"logs":[],
    "peak":0,"conns":0,
}


# ─── Меню ───────────────────────────────────────────────────────────────────

def menu(options, title=""):
    sel = 0

    def render():
        lines = []
        for i, o in enumerate(options):
            if i == sel:
                lines.append(f"  [bold bright_white on rgb(0,130,170)]   {o:<44}[/]")
            else:
                lines.append(f"  [dim]   {o}[/]")
        return Panel(
            Align.center("\n" + "\n\n".join(lines) + "\n"),
            title=f"[bold bright_cyan] {title} [/]" if title else None,
            box=ROUNDED, border_style="bright_cyan", padding=(1,4), width=58,
        )

    if sys.platform == "win32":
        import msvcrt
        while True:
            console.clear(); console.print()
            console.print(Align.center(render()))
            console.print(Align.center("[dim cyan]стрелки — навигация    enter — выбрать[/]"))
            k = msvcrt.getch()
            if k in (b'\xe0',b'\x00'):
                a = msvcrt.getch()
                if a == b'H': sel = (sel-1) % len(options)
                elif a == b'P': sel = (sel+1) % len(options)
            elif k == b'\r': return sel
    else:
        import tty, termios
        fd = sys.stdin.fileno()
        old = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            while True:
                console.clear(); console.print()
                console.print(Align.center(render()))
                console.print(Align.center("[dim cyan]стрелки — навигация    enter — выбрать[/]"))
                c = sys.stdin.read(1)
                if c == '\x1b':
                    if sys.stdin.read(1) == '[':
                        d = sys.stdin.read(1)
                        if d == 'A': sel = (sel-1) % len(options)
                        elif d == 'B': sel = (sel+1) % len(options)
                elif c in ('\r','\n'): return sel
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old)


# ─── Инициализация ──────────────────────────────────────────────────────────

def init_all():
    console.clear()
    console.print()

    count = random.randint(420, 580)
    devices = [gen_device() for _ in range(count)]
    proxy_count = random.randint(3200, 5500)

    total_steps = count + proxy_count

    console.print(Align.center(
        f"[bold bright_cyan]Загрузка[/] [dim]—[/] [white]{count} устройств, {proxy_count} прокси[/]\n"
    ))

    with Progress(
        SpinnerColumn("dots12", style="bright_cyan"),
        TextColumn("[white]{task.description}[/]", justify="left"),
        BarColumn(bar_width=52, style="grey23", complete_style="bright_cyan", finished_style="bright_green"),
        TextColumn("[bright_cyan]{task.percentage:>3.0f}%[/]"),
        TimeElapsedColumn(),
        console=console, expand=False,
    ) as prog:
        task = prog.add_task("", total=total_steps)

        # устройства
        for dev in devices:
            u = dev["uuid"][:13]
            o = dev["os"]
            if len(o) > 26: o = o[:26] + ".."
            prog.update(task, description=f"{dev['hostname']:<22} {u}..  {o}")
            time.sleep(random.uniform(0.02, 0.08))
            prog.advance(task)

        # прокси
        loaded = 0
        while loaded < proxy_count:
            batch = random.randint(30, 150)
            batch = min(batch, proxy_count - loaded)
            loaded += batch
            p = fake_proxy()
            prog.update(task, description=f"прокси {loaded}/{proxy_count}  {p}")
            prog.update(task, completed=count + loaded)
            time.sleep(random.uniform(0.005, 0.02))

        prog.update(task, description=f"[bright_green]Загружено {count} устройств, {proxy_count} прокси[/]")

    time.sleep(0.4)
    console.print()

    # превью таблица
    table = Table(
        box=ROUNDED, border_style="grey35",
        header_style="bold white on grey11",
        row_styles=["", "dim"],
        show_lines=False, padding=(0,1),
    )
    table.add_column("Устройство", style="bold cyan", width=24, no_wrap=True)
    table.add_column("UUID", style="dim", width=15, no_wrap=True)
    table.add_column("ОС", style="white", width=30, no_wrap=True)
    table.add_column("Ядро", style="dim", width=22, no_wrap=True)
    table.add_column("Регион", style="yellow", width=20, no_wrap=True)
    table.add_column("IP", style="green", width=16, no_wrap=True)
    table.add_column("Пинг", style="bright_cyan", width=8, justify="right")

    sample = random.sample(devices, min(25, len(devices)))
    for d in sample:
        pc = "green" if d["latency"]<100 else "yellow" if d["latency"]<350 else "red"
        table.add_row(
            d["hostname"], d["uuid"][:13]+"..", d["os"], d["kernel"],
            d["region"], d["ip"], f"[{pc}]{d['latency']:.0f}ms[/]",
        )

    console.print(table)
    console.print()

    win_c = sum(1 for d in devices if d["is_win"])
    lin_c = count - win_c
    reg_c = len(set(d["region"] for d in devices))
    avg_p = sum(d["latency"] for d in devices) / count

    console.print(Align.center(
        f"[bold bright_cyan]{count}[/] [dim]устройств[/]    "
        f"[bold blue]{win_c}[/] [dim]windows[/]    "
        f"[bold yellow]{lin_c}[/] [dim]linux[/]    "
        f"[bold green]{reg_c}[/] [dim]регионов[/]    "
        f"[dim]пинг[/] [bold bright_cyan]{avg_p:.0f}ms[/]    "
        f"[bold magenta]{proxy_count}[/] [dim]прокси[/]"
    ))

    return devices, proxy_count


# ─── Ввод цели ──────────────────────────────────────────────────────────────

def ask_target():
    console.print()
    target = Prompt.ask("  [bold bright_cyan]Цель[/]", default="example.com", console=console)
    port = Prompt.ask("  [bold bright_cyan]Порт[/]", default="443", console=console)
    threads = Prompt.ask("  [bold bright_cyan]Потоков на ноду[/]", default="64", console=console)
    duration = Prompt.ask("  [bold bright_cyan]Длительность (сек, 0=бесконечно)[/]", default="0", console=console)
    return {"target":target,"port":int(port),"threads":int(threads),"duration":int(duration)}


# ─── Воркер ─────────────────────────────────────────────────────────────────

def gen_log(devices):
    d = random.choice(devices)
    m = random.choice(METHODS)
    s = random.choice(STATUSES)
    l = fake_latency()
    sz = random.randint(64, 16384)
    p = fake_proxy()
    ts = datetime.now().strftime("%H:%M:%S.") + f"{random.randint(0,999):03d}"
    ua = random.choice(UA_SHORT)
    path = random.choice(PATHS)
    sc = "green" if s<300 else "yellow" if s<400 else "bright_red"
    lc = "green" if l<100 else "yellow" if l<400 else "red"
    t = (
        f"[dim]{ts}[/]  "
        f"[cyan]{d['hostname']:<24}[/]"
        f"[dim magenta]{p:<32}[/]"
        f"[white]{m:<7}[/]"
        f"[dim]{path:<18}[/]"
        f"[{sc}]{s}[/]  "
        f"[{lc}]{l:>5.0f}ms[/]  "
        f"[dim]{sz:>5}B[/]  "
        f"[dim]{ua}[/]"
    )
    return t, s, sz


def worker(devices, cfg):
    while stats["running"]:
        for _ in range(random.randint(10, 80)):
            if not stats["running"]: return
            t, s, sz = gen_log(devices)
            stats["reqs"] += 1
            stats["bytes"] += sz
            if s < 400: stats["ok"] += 1
            else: stats["fail"] += 1
            stats["logs"].append(t)
            if len(stats["logs"]) > MAX_LOGS:
                stats["logs"] = stats["logs"][-MAX_LOGS:]
        el = time.time() - stats["t0"] if stats["t0"] else 1
        rps = stats["reqs"] / max(el, 0.01)
        if rps > stats["peak"]: stats["peak"] = rps
        stats["conns"] = random.randint(
            len(devices)*cfg["threads"]-300,
            len(devices)*cfg["threads"]+300,
        )
        time.sleep(random.uniform(0.02, 0.12))


# ─── Дашборд ────────────────────────────────────────────────────────────────

def dashboard(cfg, proxy_count):
    lay = Layout()
    lay.split_column(
        Layout(name="h", size=5),
        Layout(name="b"),
        Layout(name="f", size=3),
    )

    el = time.time() - stats["t0"] if stats["t0"] else 0
    rps = stats["reqs"] / max(el, 0.01)
    sr = stats["ok"] / max(stats["reqs"], 1) * 100
    m, s = int(el)//60, int(el)%60
    dur = "бесконечно" if cfg["duration"]==0 else f"{cfg['duration']}с"

    hdr = (
        f"\n"
        f"   [bold bright_cyan]ЦЕЛЬ[/]  [white]{cfg['target']}:{cfg['port']}[/]"
        f"      [bold bright_cyan]НОДЫ[/]  [green]{len(cfg['devices'])}[/]"
        f"      [bold bright_cyan]ПОТОКИ[/]  [white]{cfg['threads']*len(cfg['devices']):,}[/]"
        f"      [bold bright_cyan]ПРОКСИ[/]  [magenta]{proxy_count:,}[/]"
        f"      [bold bright_cyan]ВРЕМЯ[/]  [white]{m:02d}:{s:02d}[/]"
    )

    lay["h"].update(Panel(hdr, box=HEAVY, border_style="bright_cyan"))

    body = Layout()
    body.split_row(Layout(name="st", size=34), Layout(name="lg"))
    lay["b"].update(body)

    sc = "bright_green" if sr>85 else "yellow" if sr>60 else "bright_red"
    bw = 20
    bf = int(sr/100*bw)
    bar = f"[{sc}]{'█'*bf}[/][grey23]{'░'*(bw-bf)}[/]"

    st = (
        f"\n"
        f"  [bold bright_cyan]ЗАПРОСЫ[/]\n"
        f"  [bold white]{stats['reqs']:>14,}[/]\n\n"
        f"  [bold green]УСПЕШНЫЕ[/]\n"
        f"  [green]{stats['ok']:>14,}[/]\n\n"
        f"  [bold bright_red]ОШИБКИ[/]\n"
        f"  [bright_red]{stats['fail']:>14,}[/]\n\n"
        f"  [bold bright_cyan]СКОРОСТЬ[/]\n"
        f"  [white]{rps:>12,.0f} req/s[/]\n\n"
        f"  [bold bright_cyan]ПИКОВАЯ[/]\n"
        f"  [white]{stats['peak']:>12,.0f} req/s[/]\n\n"
        f"  [bold bright_cyan]ТРАФИК[/]\n"
        f"  [white]{format_bytes(stats['bytes']):>14}[/]\n\n"
        f"  [bold bright_cyan]СОЕДИНЕНИЯ[/]\n"
        f"  [white]{max(stats['conns'],0):>14,}[/]\n\n"
        f"  [bold bright_cyan]УСПЕХ[/]\n"
        f"  [{sc}]{sr:>12.1f}%[/]\n"
        f"  {bar}\n"
    )

    body["st"].update(Panel(st, title="[bold bright_cyan] Статистика [/]", box=ROUNDED, border_style="grey35"))

    ll = stats["logs"][-MAX_LOGS:]
    lc = "\n".join(ll) if ll else "[dim]Ожидание данных...[/]"
    body["lg"].update(Panel(lc, title="[bold bright_cyan] Трафик [/]", box=ROUNDED, border_style="grey35"))

    dot = "[bold bright_green]●[/]" if stats["running"] else "[red]●[/]"
    lay["f"].update(Panel(
        Align.center(f"{dot} [dim]АТАКА ВЫПОЛНЯЕТСЯ[/]    [dim cyan]Ctrl+C для остановки[/]"),
        box=SIMPLE_HEAVY, border_style="grey23",
    ))

    return lay


# ─── Атака ──────────────────────────────────────────────────────────────────

def run_attack(devices, cfg, proxy_count):
    cfg["devices"] = devices
    stats["reqs"]=0; stats["ok"]=0; stats["fail"]=0; stats["bytes"]=0
    stats["t0"]=time.time(); stats["running"]=True; stats["logs"]=[]
    stats["peak"]=0; stats["conns"]=0

    threads = []
    for _ in range(6):
        t = threading.Thread(target=worker, args=(devices,cfg), daemon=True)
        t.start(); threads.append(t)

    try:
        with Live(dashboard(cfg, proxy_count), console=console, refresh_per_second=10, screen=True) as live:
            while stats["running"]:
                live.update(dashboard(cfg, proxy_count))
                time.sleep(0.1)
                if cfg["duration"]>0 and time.time()-stats["t0"]>=cfg["duration"]:
                    stats["running"] = False
    except KeyboardInterrupt:
        stats["running"] = False

    for t in threads: t.join(timeout=2)
    report(cfg)


# ─── Отчет ──────────────────────────────────────────────────────────────────

def report(cfg):
    console.clear()
    el = time.time()-stats["t0"] if stats["t0"] else 0
    rps = stats["reqs"]/max(el,0.01)
    sr = stats["ok"]/max(stats["reqs"],1)*100
    m,s = int(el)//60, int(el)%60

    t = Table(
        box=DOUBLE, border_style="bright_cyan", show_header=False,
        padding=(0,4), width=52, title="[bold bright_cyan] Отчет [/]",
    )
    t.add_column("", style="bold bright_cyan", width=18)
    t.add_column("", style="white", width=28)
    t.add_row("Цель", f"{cfg['target']}:{cfg['port']}")
    t.add_row("Длительность", f"{m}м {s}с")
    t.add_row("Устройства", str(len(cfg['devices'])))
    t.add_row("Потоки", f"{cfg['threads']*len(cfg['devices']):,}")
    t.add_row("","")
    t.add_row("Всего запросов", f"{stats['reqs']:,}")
    t.add_row("Успешных", f"[green]{stats['ok']:,}[/]")
    t.add_row("Ошибок", f"[bright_red]{stats['fail']:,}[/]")
    t.add_row("Процент успеха", f"{sr:.1f}%")
    t.add_row("Средняя скорость", f"{rps:,.0f} req/s")
    t.add_row("Пиковая скорость", f"{stats['peak']:,.0f} req/s")
    t.add_row("Отправлено", format_bytes(stats['bytes']))

    console.print()
    console.print(Align.center(t))
    console.print()
    console.print(Align.center("[dim]Enter — вернуться в меню[/]"))
    input()


# ─── Main ───────────────────────────────────────────────────────────────────

def main():
    while True:
        ch = menu(["Запуск", "Выход"], "Панель управления")

        if ch == 0:
            devices, proxy_count = init_all()

            console.print()
            console.print(Align.center(Panel(
                "[bold bright_green]  Все системы готовы  [/]",
                box=ROUNDED, border_style="bright_green", width=44,
            )))

            cfg = ask_target()
            total = cfg["threads"] * len(devices)

            console.print()
            console.print(Align.center(Panel(
                f"  [bold bright_cyan]Цель[/]         [white]{cfg['target']}:{cfg['port']}[/]\n"
                f"  [bold bright_cyan]Устройства[/]   [green]{len(devices)}[/]\n"
                f"  [bold bright_cyan]Потоки[/]       [white]{total:,}[/]\n"
                f"  [bold bright_cyan]Прокси[/]       [magenta]{proxy_count:,}[/]\n"
                f"  [bold bright_cyan]Время[/]        [white]{'бесконечно' if cfg['duration']==0 else str(cfg['duration'])+'с'}[/]",
                title="[bold bright_cyan] Подтверждение [/]",
                box=DOUBLE, border_style="bright_cyan", width=48, padding=(1,3),
            )))

            c = menu(["Запустить","Отмена"], "")
            if c == 0:
                run_attack(devices, cfg, proxy_count)

        elif ch == 1:
            console.clear()
            console.print()
            console.print(Align.center(Panel(
                "[bold bright_cyan]Сессия завершена[/]",
                box=HEAVY, border_style="bright_cyan", width=40, padding=(1,2),
            )))
            console.print()
            sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.clear()
        console.print("\n[bold bright_cyan]Прервано.[/]\n")
        sys.exit(0)
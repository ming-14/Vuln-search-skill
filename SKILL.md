---
name: vuln-search
description: Use when searching for CVE vulnerabilities, finding exploits, or doing privilege escalation research.
---

# 漏洞搜索与利用工具箱

本SKILL提供NVD、Exploit-DB、CISA-KEV、Vulners数据库搜索

## 搜索策略（重要）

**必须用不同关键词批量搜索！** 描述质量参差不齐，很多 CVE 不包含 "privilege escalation" 这些词，所以需要大批量搜索NVD、Exploit-DB、CISA-KEV！

**多来源搜索，切记不要依赖单一来源**

### 为什么需要多关键词搜索

| 问题 | 例子 |
|------|------|
| 描述只写技术修复 | 如CVE-2026-31431 只写 "algif_aead - Revert to operating out-of-place" |
| 不写安全影响 | 没有 "privilege"、"escalation" 这些词 |
| 搜不到 | 用 "privilege escalation" 搜不到这个漏洞 |

### NVD 批量搜索方法

NVD请使用`NVD-CLI/main.py`搜索，命令行直接支持多关键词

```bash
# 多个 -k 参数，同时搜多个关键词
python NVD-CLI/main.py cve search -k "linux" -k "kernel" -k "privilege" --severity-v3 HIGH # 第一轮通用搜索
python NVD-CLI/main.py cve search -k "nf_tables" -k "algif" -k "overlayfs" --severity-v3 HIGH # 第二轮技术搜索
python NVD-CLI/main.py cve search -k "dirty" -k "cow" --severity-v3 HIGH # 第三轮搜索
python NVD-CLI/main.py cve search --cwe CWE-269 --cwe CWE-416 --severity-v3 HIGH # 第四轮分类搜索

# 组合搜索：关键词 + CWE + KEV
python NVD-CLI/main.py cve search -k "linux" -k "local" --cwe CWE-269 --has-kev --severity-v3 HIGH
```

### 本地 rg 批量搜索方法

```bash
# 单条命令，管道符分隔多个关键词
rg -i "linux.*local.*root\|linux.*kernel.*privilege\|dirty.*cow\|dirty.*pipe\|nf_tables\|algif\|overlayfs\|suid.*local\|sudo.*privilege" Exploit-DB/files_exploits.csv

# 或者用 -e 参数指定多个模式
rg -i -e "linux.*local.*root" -e "nf_tables" -e "dirty.*pipe" Exploit-DB/files_exploits.csv
```

### 搜索关键词清单

| 类别 | 关键词 |
|------|--------|
| **通用** | `linux local root`, `linux privilege escalation`, `linux local privilege` |
| **内核** | `kernel local privilege`, `kernel Use-After-Free`, `kernel race condition` |
| **模块** | `nf_tables`, `algif_aead`, `overlayfs`, `netfilter`, `bpf` |
| **Dirty** | `dirty cow`, `dirty pipe`, `dirty sock` |
| **SUID** | `suid privilege`, `suid local root`, `suid escalation` |
| **sudo** | `sudo privilege`, `sudoedit`, `sudo heap` |
| **CWE** | `CWE-269`, `CWE-416`, `CWE-362`, `CWE-122`, `CWE-787` |

...等等，仅供参考

## 工具使用

### NVD CLI — 搜索 CVE 漏洞

```bash
python NVD-CLI/main.py cve search -k "linux kernel privilege" --severity-v3 HIGH # 基本搜索
python NVD-CLI/main.py cve search --cwe CWE-269 -l 20 # 按 CWE 搜索
python NVD-CLI/main.py cve search --pub-start 2026-01-01 --pub-end 2026-12-31 # 按日期搜索
python NVD-CLI/main.py cve search --has-kev --severity-v3 HIGH # 搜索已知被利用漏洞
python NVD-CLI/main.py cve get CVE-2026-31431 -o json # 查询特定 CVE
python NVD-CLI/main.py cve latest -d 30 -s CRITICAL # 最近 N 天的新 CVE
```

### ripgrep — 本地搜索 Exploit-DB

```bash
rg -i "linux.*local.*root" Exploit-DB/files_exploits.csv # 搜索 Linux 提权 exploit
rg -i "CVE-2026-31431" Exploit-DB/files_exploits.csv # 搜索特定 CVE
rg -i "dirty.*pipe\|dirty.*cow" Exploit-DB/files_exploits.csv # 搜索关键词
rg -i "kernel.*local.*privilege" Exploit-DB/files_exploits.csv # 搜索内核 exploit
rg -i "DirtyPipe" Exploit-DB/files_exploits.csv | cut -d',' -f1# 输出 EDB-ID
```

### CISA KEV — 已知被利用漏洞

```bash
rg -i "CVE-2026-31431" CISA-KEV/known_exploited_vulnerabilities.json # 搜索特定 CVE
rg -i "linux" CISA-KEV/known_exploited_vulnerabilities.json # 搜索 linux 相关
```

### Vulners 搜索

Vulners 不适用大规模搜索，更适合查缺补漏，启发思路

APIKEY：`Vulners API Docs\apikey.toml`

API文档：
- `Vulners API Docs\en\vulners-api.md`
- `Vulners API Docs\en\vulners-api-alerts.md`
- `Vulners API Docs\en\vulners-api-audit.md`
- `Vulners API Docs\en\vulners-api-collections.md`
- `Vulners API Docs\en\vulners-api-reporting.md`
- `Vulners API Docs\en\vulners-api-search.md`

## 漏洞利用流程

### 流程图

```
目标基本信息
    ↓
确认影响范围
    ↓
NVD CLI 搜索 CVE & 本地 rg 搜索 Exploit-DB、CISA KEV & 搜索 Vulners 
    ↓
找到 EDB-ID 或 GitHub 链接
    ↓
下载 exploit
    ↓
执行
```

也可启发思路，自主挖掘更多信息

## 更新数据

```bash
# 更新 CISA KEV
cd CISA-KEV && update.bat

# 更新 Exploit-DB 索引
cd Exploit-DB && update_files_exploits.csv.bat

# 更新 NVD 缓存（自动）
python main.py cve search -k "test" --no-cache
```

---

- 注意Github下载，由于中国大陆网络问题，请使用镜像站下载Github资源：
    https://v4.gh-proxy.org/{Github链接}，可下载分支源码，raw文件，Release源码，Release文件，gist，api，git

- rg搜索：如果是Windows系统x86_64架构，SKILL的根目录`rg.exe`可用，其他系统及架构请自行下载

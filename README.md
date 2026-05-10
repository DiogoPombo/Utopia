Utopia is a **PowerShell-based log coloring pipeline** that enhances console readability by applying ANSI colors to text streams.  
It is designed to process continuous output from any command-line program, highlighting errors, warnings, success messages, and informational logs in real time.


---


## ✨ Features

- **Real-time log filtering**: Processes input streams line by line.
- **Error suppression**: Ignores redundant CMD error messages in both Portuguese and English.
- **Stacktrace detection**: Highlights Java-style stacktraces (`at com.example.Class.method(...)`, `Caused by:`).
- **Keyword-based coloring**: Applies colors to common log keywords (`ERROR`, `WARN`, `SUCCESS`, `INFO`).
- **WebLogic tag support**: Recognizes `<ERROR>`, `<WARNING>`, `<NOTICE>`, `<INFO>` tags.

---


## 🎨 Color Mapping

| Pattern | Example | Color |
|---------|---------|-------|
| Errors / Exceptions | `NullPointerException`, `Caused by:` | 🔴 Red |
| Warnings | `WARNING`, `ALERT`, `ATENCAO` | 🟡 Yellow |
| Success / Ready | `SUCCESS`, `READY`, `RUNNING`, `LOADED` | 🟢 Green |
| Info / Debug | `INFO`, `DEBUG` | 🔵 Cyan |
| Neutral | Any other text | ⚪ Default |

---


## ⚙️ Usage

Pipe the output of any command into Utopia:

myprogram.exe 2>&1 | powershell -NoProfile -ExecutionPolicy Bypass -File Utopia.ps1
This will:

Capture both stdout and stderr (2>&1).

Send the combined output into Utopia.

Apply coloring rules line by line.

Print the processed output back to the console.


Raw output Example:

- INFO: Starting server → Cyan

- WARNING: Config file missing → Yellow

- Exception in thread "main" java.lang.NullPointerException → Red


---


🧩 Implementation Notes

Uses $input | ForEach-Object { ... } to process streaming data.

Relies on regex patterns to classify log lines.

Applies ANSI escape codes ([char]27) for coloring.

Handles localized CMD error messages (Portuguese split across two lines, English in one line).


👨‍💻 Author

Developed by Diogo Santos Pombo (2026).

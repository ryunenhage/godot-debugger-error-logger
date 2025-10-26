# Godot Debugger Error Logger

Automatically logs errors and warnings from the Godot Editor's **Debugger > Errors** tab to a file.

## Why?

The reason is to smoothly convey the contents of the debugger tab to LLM.
By default, Godot's file logging feature (`file_logging/enable_file_logging=true`) only captures console output (stdout/stderr), but **does not log the errors shown in the Debugger's Errors tab**. This plugin solves that problem by directly accessing the Debugger's error tree and saving all errors to a log file.

No more copy-pasting errors manually!

## Features

- ✅ Automatically logs all errors from the Debugger > Errors tab
- ✅ Preserves error hierarchy and details
- ✅ Supports both English and Japanese Godot Editor
- ✅ Timestamp for each error
- ✅ No duplicate logging (each error logged once)
- ✅ Configurable log file path and check interval

## Installation

### Method 1: Per-Project Installation

1. Download or clone this repository
2. Copy the `error_logger` folder to your Godot project's `addons/` directory
3. Open your project in Godot
4. Go to `Project` → `Project Settings` → `Plugins`
5. Enable the **Error Logger** plugin

## Usage

Once enabled, the plugin automatically monitors the Debugger's Errors tab and logs all errors to:

**Log file location:**
- `res://debugger_logs/debugger_errors.log` (in your project's root directory)

### Example Log Output

```
============================================================
[2025-10-27T05:42:39]
0:00:01:716
GDScript::reload: The local variable "header_line" is declared but never used in the block. If this is intended, prefix it with an underscore: "_header_line".
  <GDScript エラー>
    UNUSED_VARIABLE
  <GDScript ソース>
    data_loader.gd:99 @ GDScript::reload()
============================================================
```

## Configuration

You can customize the plugin by editing `plugin.gd`:

```gdscript
var log_file_path = "user://debugger_errors.log"  # Path to the log file
var check_interval = 1.0  # How often to check for new errors (in seconds)
```

## Compatibility

- **Godot Version:** 4.x (tested on 4.5)
- **Languages:** English and Japanese editor UI

## How It Works

This plugin uses a "GUI hacking" approach:
1. Finds the `EditorDebuggerNode` in the editor's scene tree
2. Locates the **Errors** tab's `Tree` widget
3. Periodically checks for new error entries
4. Extracts error details and saves them to a log file

**Note:** This relies on Godot's internal editor structure, which may change between versions.

## Known Limitations

- Only captures errors that appear in the Debugger > Errors tab (not Output tab)
- Requires the game to be running at least once for the debugger to initialize

## License

MIT License - see [LICENSE](LICENSE) file

## Contributing

Issues and pull requests are welcome!

## Credits

Developed by [@toryufuco](https://github.com/toryufuco)



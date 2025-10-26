@tool
extends EditorPlugin

# Godot Debugger Error Logger
# Automatically logs errors from the Debugger > Errors tab to a file
# Author: toryufuco
# License: MIT

# Configuration
var log_file_path = "user://debugger_errors.log"  # Path to the log file
var check_interval = 1.0  # How often to check for new errors (in seconds)

# Internal variables
var error_tree: Tree = null
var timer: Timer = null
var logged_errors = {}

func _enter_tree():
	print("==================================================")
	print("ERROR LOGGER PLUGIN ACTIVATED")
	print("Log file: ", log_file_path)
	print("==================================================")

	await get_tree().create_timer(2.0).timeout

	# Start timer to periodically check for errors
	timer = Timer.new()
	timer.wait_time = check_interval
	timer.timeout.connect(_check_errors)
	add_child(timer)
	timer.start()
	print("[ErrorLogger] Monitoring started! Will search for error tree...")

func _exit_tree():
	print("[ErrorLogger] Plugin deactivated")
	if timer:
		timer.queue_free()

func _find_node_by_class(node: Node, target_class: String):
	"""Recursively search for a node by class name"""
	if node.get_class() == target_class:
		return node
	for child in node.get_children():
		var result = _find_node_by_class(child, target_class)
		if result:
			return result
	return null

func _find_error_tree(node: Node):
	"""Find the Tree widget in the Debugger Errors tab"""
	# Support both Japanese ("エラー") and English ("Errors") versions
	var node_name = node.name
	if (node_name == "エラー" or node_name == "Errors") and node is VBoxContainer:
		# Search for Tree widget in children
		for child in node.get_children():
			if child is Tree:
				print("[ErrorLogger] Found error tree in node: ", node_name)
				return child

	for child in node.get_children():
		var result = _find_error_tree(child)
		if result:
			return result

	return null

func _check_errors():
	"""Check for new errors in the debugger"""
	# If error tree hasn't been found yet, try to find it
	if not error_tree:
		var debugger_node = _find_node_by_class(get_tree().root, "EditorDebuggerNode")
		if debugger_node:
			error_tree = _find_error_tree(debugger_node)
			if error_tree:
				print("[ErrorLogger] Error Tree found! Now monitoring errors.")
		return

	var root = error_tree.get_root()
	if not root:
		return

	# Process only top-level items (each represents one error)
	var child = root.get_first_child()
	while child:
		_process_top_level_error(child)
		child = child.get_next()

func _process_top_level_error(item: TreeItem):
	"""Process a single error entry and its children"""
	if not item:
		return

	# Get top-level text
	var error_text = item.get_text(0)
	var detail_text = item.get_text(1) if error_tree.columns > 1 else ""

	if error_text.length() == 0:
		return

	# Skip if already logged (use both timestamp and detail text for uniqueness)
	var unique_key = error_text + "|" + detail_text
	var error_hash = unique_key.hash()
	if logged_errors.has(error_hash):
		return

	logged_errors[error_hash] = true

	# Collect all error information
	var error_lines = []
	error_lines.append(error_text)
	if detail_text.length() > 0:
		error_lines.append(detail_text)

	# Include child items (detailed information)
	var child = item.get_first_child()
	while child:
		var child_text = child.get_text(0)
		var child_detail = child.get_text(1) if error_tree.columns > 1 else ""

		if child_text.length() > 0:
			error_lines.append("  " + child_text)
		if child_detail.length() > 0:
			error_lines.append("    " + child_detail)

		child = child.get_next()

	# Save to file
	_save_error_block(error_lines)

func _save_error_block(error_lines: Array):
	"""Save error block to log file"""
	var log_file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
	if not log_file:
		log_file = FileAccess.open(log_file_path, FileAccess.WRITE)

	if log_file:
		log_file.seek_end()
		log_file.store_line("")
		log_file.store_line("============================================================")
		log_file.store_line("[%s]" % Time.get_datetime_string_from_system())

		for line in error_lines:
			log_file.store_line(line)

		log_file.store_line("============================================================")
		log_file.close()

		# Print preview
		if error_lines.size() > 0:
			var preview = error_lines[0].substr(0, min(80, error_lines[0].length()))
			print("[ErrorLogger] Logged error: ", preview)

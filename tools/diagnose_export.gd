extends EditorScript

func _run() -> void:
    print("=== ANDROID EXPORT DIAGNOSTIC ===")
    var cfg := ConfigFile.new()
    var err := cfg.load("res://export_presets.cfg")
    print("Preset load result: ", err)
    if err != OK:
        return
    for section in cfg.get_sections():
        print("Section: ", section)
        for key in cfg.get_section_keys(section):
            var value = cfg.get_value(section, key)
            if key.contains("password") or key.contains("pass"):
                value = "[REDACTED]"
            print("  ", key, " = ", value)
    print("=== END DIAGNOSTIC ===")

extends EditorScript

func _run() -> void:
    print("=== ANDROID EXPORT DIAGNOSTIC ===")
    var presets = EditorExport.get_export_presets()
    print("Preset count: ", presets.size())
    for preset in presets:
        var platform = preset.get_platform()
        print("Preset: ", preset.get_name(), " platform: ", platform.get_name())
        print("Export path: ", preset.get_export_path())
        print("Can export: ", platform.can_export(preset, true))
        print("Has valid export configuration: ", platform.has_valid_export_configuration(preset, true))
    print("=== END DIAGNOSTIC ===")

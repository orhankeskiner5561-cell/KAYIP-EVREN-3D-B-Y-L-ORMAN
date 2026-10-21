extends EditorScript

func _run() -> void:
    print("=== ANDROID EXPORT DIAGNOSTIC ===")
    var presets = EditorExport.get_export_presets()
    print("Preset count: ", presets.size())
    for preset in presets:
        var platform = preset.get_platform()
        print("Preset: ", preset.get_name(), " platform: ", platform.get_name())
        print("Export path: ", preset.get_export_path())
        for method_name in ["can_export", "has_valid_export_configuration", "has_valid_project_configuration"]:
            if platform.has_method(method_name):
                print("Method exists: ", method_name)
            else:
                print("Method not exposed: ", method_name)
    print("=== END DIAGNOSTIC ===")

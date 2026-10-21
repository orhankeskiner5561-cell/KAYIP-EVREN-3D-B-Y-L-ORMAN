extends Node3D

var camera: Camera3D
var player: CharacterBody3D
var yaw := 0.0
var pitch := -0.08
var joystick_id := -1
var look_id := -1
var joystick_origin := Vector2.ZERO
var joystick_pos := Vector2.ZERO
var move_axis := Vector2.ZERO
var last_look := Vector2.ZERO
var night := false
var sun: DirectionalLight3D
var world: WorldEnvironment
var hud: Control

func _ready() -> void:
 _make_world()
 _make_hud()

func _make_world() -> void:
 var ground := MeshInstance3D.new()
 var plane := PlaneMesh.new()
 plane.size = Vector2(120,120)
 ground.mesh = plane
 ground.material_override = _mat(Color(0.16,0.29,0.13))
 add_child(ground)
 var collider := StaticBody3D.new()
 var shape := CollisionShape3D.new()
 var box := BoxShape3D.new()
 box.size = Vector3(120,1,120)
 shape.shape = box
 shape.position.y = -0.5
 collider.add_child(shape)
 add_child(collider)
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261021
 for i in range(95):
  var x := rng.randf_range(-53,53)
  var z := rng.randf_range(-53,53)
  if absf(x) < 5 and absf(z) < 5:
   continue
  var height := rng.randf_range(5,11)
  _cylinder(Vector3(x,height/2,z),0.25,height,Color(0.22,0.12,0.065))
  for j in range(3):
   _sphere(Vector3(x+rng.randf_range(-0.6,0.6),height*0.73+j*0.5,z+rng.randf_range(-0.6,0.6)),Vector3(1.8,1.1,1.8),Color(0.035+rng.randf_range(0,0.04),0.18+rng.randf_range(0,0.08),0.07))
 for i in range(22):
  var x := rng.randf_range(-55,55)
  var z := rng.randf_range(-55,55)
  if absf(x)<7 and absf(z)<7: continue
  var h := rng.randf_range(7,22)
  _cylinder(Vector3(x,h/2,z),rng.randf_range(1.3,3.1),h,Color(0.28,0.33,0.29))
 sun = DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-48,35,0)
 sun.light_energy = 1.35
 add_child(sun)
 world = WorldEnvironment.new()
 var env := Environment.new()
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color(0.53,0.7,0.85)
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color(0.7,0.78,0.84)
 env.ambient_light_energy = 0.65
 env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
 world.environment = env
 add_child(world)
 player = CharacterBody3D.new()
 player.position = Vector3(0,1.5,0)
 add_child(player)
 var body_shape := CollisionShape3D.new()
 var capsule := CapsuleShape3D.new()
 capsule.radius = 0.35
 capsule.height = 1.8
 body_shape.shape = capsule
 player.add_child(body_shape)
 camera = Camera3D.new()
 camera.current = true
 camera.position.y = 0.55
 camera.fov = 78
 player.add_child(camera)
 _update_view()

func _mat(color: Color) -> StandardMaterial3D:
 var m := StandardMaterial3D.new()
 m.albedo_color = color
 m.roughness = 0.95
 return m

func _cylinder(pos:Vector3,radius:float,height:float,color:Color) -> void:
 var mesh := CylinderMesh.new()
 mesh.top_radius = radius * 0.78
 mesh.bottom_radius = radius
 mesh.height = height
 var node := MeshInstance3D.new()
 node.mesh = mesh
 node.material_override = _mat(color)
 node.position = pos
 add_child(node)

func _sphere(pos:Vector3,scale3:Vector3,color:Color) -> void:
 var mesh := SphereMesh.new()
 mesh.radial_segments = 9
 mesh.rings = 5
 var node := MeshInstance3D.new()
 node.mesh = mesh
 node.material_override = _mat(color)
 node.position = pos
 node.scale = scale3
 add_child(node)

func _make_hud() -> void:
 var layer := CanvasLayer.new()
 add_child(layer)
 hud = Control.new()
 hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
 layer.add_child(hud)
 var label := Label.new()
 label.text = "KAYIP EVREN  |  ORMAN TESTI"
 label.position = Vector2(20,22)
 label.add_theme_font_size_override("font_size",22)
 hud.add_child(label)
 var button := Button.new()
 button.text = "GUN / GECE"
 button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
 button.position = Vector2(-170,20)
 button.size = Vector2(150,55)
 button.pressed.connect(_toggle_night)
 hud.add_child(button)

func _toggle_night() -> void:
 night = not night
 sun.light_energy = 0.12 if night else 1.35
 world.environment.background_color = Color(0.025,0.035,0.11) if night else Color(0.53,0.7,0.85)
 world.environment.ambient_light_color = Color(0.12,0.23,0.37) if night else Color(0.7,0.78,0.84)

func _input(event:InputEvent) -> void:
 if event is InputEventScreenTouch:
  if event.pressed:
   if event.position.x < get_viewport().get_visible_rect().size.x * 0.45 and joystick_id == -1:
    joystick_id = event.index
    joystick_origin = event.position
    joystick_pos = event.position
   elif look_id == -1:
    look_id = event.index
    last_look = event.position
  else:
   if event.index == joystick_id:
    joystick_id = -1
    move_axis = Vector2.ZERO
   if event.index == look_id:
    look_id = -1
 if event is InputEventScreenDrag:
  if event.index == joystick_id:
   joystick_pos = event.position
   move_axis = (joystick_pos-joystick_origin).limit_length(90)/90.0
  elif event.index == look_id:
   var delta := event.position-last_look
   yaw -= delta.x * 0.004
   pitch = clampf(pitch-delta.y*0.004,-1.25,1.25)
   last_look = event.position
   _update_view()
 if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
  yaw -= event.relative.x*0.004
  pitch = clampf(pitch-event.relative.y*0.004,-1.25,1.25)
  _update_view()

func _update_view() -> void:
 if player:
  player.rotation.y = yaw
  camera.rotation.x = pitch

func _physics_process(delta:float) -> void:
 if not player: return
 var axis := move_axis
 if Input.is_key_pressed(KEY_W): axis.y = -1
 if Input.is_key_pressed(KEY_S): axis.y = 1
 if Input.is_key_pressed(KEY_A): axis.x = -1
 if Input.is_key_pressed(KEY_D): axis.x = 1
 var dir := player.global_transform.basis * Vector3(axis.x,0,axis.y)
 player.velocity.x = dir.x*5
 player.velocity.z = dir.z*5
 player.velocity.y -= 18*delta
 player.move_and_slide()

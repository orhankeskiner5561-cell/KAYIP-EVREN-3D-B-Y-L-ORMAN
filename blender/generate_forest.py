import bpy, math, random
from mathutils import Vector
random.seed(26)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
def material(name,color,roughness=0.9):
 m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
 bs=m.node_tree.nodes.get("Principled BSDF"); bs.inputs["Base Color"].default_value=(*color,1); bs.inputs["Roughness"].default_value=roughness
 return m
ground=material("Moss ground",(0.15,0.26,0.14))
bark=material("Dark bark",(0.12,0.07,0.04))
leaf=material("Forest foliage",(0.055,0.19,0.085))
stone=material("Stone",(0.27,0.32,0.29))
glow=material("Night flora",(0.05,0.65,0.82))
def cube(name,loc,scale,mat):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc)
 o=bpy.context.object;o.name=name;o.dimensions=scale;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.data.materials.append(mat);return o
cube("Forest floor",(0,0,-0.5),(90,90,1),ground)
for i in range(55):
 x=random.uniform(-42,42);y=random.uniform(-42,42)
 h=random.uniform(3,9)
 bpy.ops.mesh.primitive_cylinder_add(vertices=10,radius=0.28,depth=h,location=(x,y,h/2))
 trunk=bpy.context.object;trunk.name="Tree trunk";trunk.data.materials.append(bark)
 for j in range(3):
  bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=1.0,location=(x+random.uniform(-.5,.5),y+random.uniform(-.5,.5),h*.7+j*.65))
  crown=bpy.context.object;crown.name="Tree crown";crown.scale=(1.7+j*.18,1.5+j*.16,1.4);crown.data.materials.append(leaf)
for i in range(15):
 x=random.uniform(-43,43);y=random.uniform(-43,43);h=random.uniform(5,19)
 bpy.ops.mesh.primitive_cone_add(vertices=9,radius1=random.uniform(1.5,3.8),radius2=.6,depth=h,location=(x,y,h/2))
 bpy.context.object.name="Rock pillar";bpy.context.object.data.materials.append(stone)
for i in range(45):
 x=random.uniform(-42,42);y=random.uniform(-42,42)
 bpy.ops.mesh.primitive_uv_sphere_add(segments=8,ring_count=4,radius=random.uniform(.15,.5),location=(x,y,.35))
 bpy.context.object.name="Glowing flora";bpy.context.object.data.materials.append(glow)
bpy.ops.wm.save_as_mainfile(filepath="/tmp/kayip_evren_v6.blend")
bpy.ops.export_scene.gltf(filepath="/tmp/kayip_evren_v6.glb",export_format='GLB')
print("KAYIP_EVREN_EXPORT_OK")

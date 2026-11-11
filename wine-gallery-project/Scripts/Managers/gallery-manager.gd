extends Node
class_name GalleryManager

@export var camera3d : Camera3D;

func _ready() -> void :
	if( !camera3d ) :
		return;
	
func _physics_process( delta: float ) -> void :
	pass;

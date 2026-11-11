extends Node
class_name MouseManager

@export var cameraManager : CameraManager;
@export var inputManager : InputManager;
@export var mouseSprite : AnimatedSprite2D;

var camera3D : Camera3D;
var prevHoveredNode : Node;
var currentHoveredNode : Node;
var mousePosition : Vector2;
var spritePosition : Vector2;



func init() -> void :
	if ( !cameraManager ) :
		print ( "mouse mgrs's ref to camera mgr is null" );
		return;
		
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN;
	camera3D = cameraManager.camera3D;
		
func update( delta : float ) -> void :
	
	mousePosition = get_viewport().get_mouse_position();
	
	spritePosition = Vector2( mousePosition.x + 20, mousePosition.y + 20 );
	mouseSprite.global_position = spritePosition;
	
	if ( inputManager.actionLeftClick.isActive) :
		if ( mouseSprite.frame >= 3 ) : 
			mouseSprite.stop();
		mouseSprite.play();
		inputManager.reset_buffer( InputManager.InputID.ACTION_LEFT_CLICK );
	
	# Reset Current Hovered Node
	currentHoveredNode = null;
	
	# Reset Last Hovered Node Back To Not Hovered
	if ( prevHoveredNode && prevHoveredNode != currentHoveredNode ) :
	
		if ( prevHoveredNode is HoverableObject ) :
			prevHoveredNode.isHovered = false;
		
	# Check If Mouse Is Hovering Over Node, Bail If Not
	var newNode : Node = get_mouse_hovered_node();
	
	if ( !newNode ) :
		return; 
		
	# Do Not Check For Hovering Over Character Or Static Bodies
	if ( newNode is CharacterBody3D || newNode is StaticBody3D ) :
		return;
	
	# Check If Hovered Node Has A Parent, Bail If Not
	var newNodeParent : Node = newNode.get_parent();
	
	if ( !newNodeParent ) :
		return;
		
	currentHoveredNode = newNodeParent;
	
	if ( currentHoveredNode is HoverableObject ) :
			
		# Set Current Hovered Node To Hovered
		currentHoveredNode.isHovered = true;
		
	prevHoveredNode = currentHoveredNode;
		

func get_mouse_hovered_node() -> Node:
	if ( !camera3D ) :
		camera3D = cameraManager.camera3D;
		print("assigned cam3d to mouse mgr");
		return;
	var rayOrigin: Vector3 = camera3D.project_ray_origin( mousePosition );
	var rayDirection: Vector3 = camera3D.project_ray_normal( mousePosition );
	
	var query: PhysicsRayQueryParameters3D = \
		PhysicsRayQueryParameters3D.create( rayOrigin, rayOrigin + rayDirection * 1000.0 );
	
	query.collision_mask = 1;
	query.collide_with_areas = true;
	query.collide_with_bodies = false;
	
	var result: Dictionary = \
		camera3D.get_world_3d().direct_space_state.intersect_ray( query );
	
	if ( result.is_empty() ) :
		return null;
	
	return result[ "collider" ] as Node;

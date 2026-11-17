extends Node
class_name MouseManager

@export var galleryManager : GalleryManager;
@export var camera3d : Camera3D;
@export var mouseSprite : AnimatedSprite2D;

var prevHoveredNode : Node;
var currentHoveredNode : Node;
var mousePosition : Vector2;
var spritePosition : Vector2;


func init() -> void :
	
	if ( !galleryManager ) :
		return;
		
func update( delta : float ) -> void :
	
	mousePosition = get_viewport().get_mouse_position();
	
	#spritePosition = Vector2( mousePosition.x + 20, mousePosition.y + 20 );
	#mouseSprite.global_position = spritePosition;
	
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
	
	if ( !camera3d ) :
		return;
		
	var rayOrigin: Vector3 = camera3d.project_ray_origin( mousePosition );
	var rayDirection: Vector3 = camera3d.project_ray_normal( mousePosition );
	
	var query: PhysicsRayQueryParameters3D = \
		PhysicsRayQueryParameters3D.create( rayOrigin, rayOrigin + rayDirection * 1000.0 );
	
	query.collision_mask = 1;
	query.collide_with_areas = true;
	query.collide_with_bodies = false;
	
	var result: Dictionary = \
		camera3d.get_world_3d().direct_space_state.intersect_ray( query );
	
	if ( result.is_empty() ) :
		return null;
	
	return result[ "collider" ] as Node;

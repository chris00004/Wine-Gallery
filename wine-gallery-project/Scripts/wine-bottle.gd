extends HoverableObject
class_name WineBottle

@export var producerString : String = "";
@export var grapeString : String = "";
@export var countryString : String = "";
@export var regionString : String = "";
@export var vintageYearString : String = "";
@export var priceString : String = "";
@export var alcPercentageString : String = "";

@export var websiteLinkString : String = "";

@export var producerDescription : String = "";

var isFocused : bool = false;
var initialLocalRotationX : float;

@export var galleryManager : GalleryManager;
@export var area3D : Area3D;

var rotationAxis : Vector3 = Vector3.UP;
var dragStrength : float = 0.05;
var deceleration : float = 3.0;
var rotationSpeed : float = 0.0;
var moveSpeed : float = 8.0;

var isLeftMouseDown : bool = false;
var isInDraggableRange : bool = false;
var followPoint : Vector3;


func init() -> void :
	
	super();
	visible = true;
	isActive = true;
	initialLocalRotationX = rotation.x;
	
func update( delta : float ) -> void :
	
	super( delta );
	process_states( delta );
	area3D.global_rotation_degrees = Vector3.ZERO;
	
			
# Get Mouse Input For Dragging
func _input( event ) :
	
	if ( !isFocused || !isInDraggableRange ) :
		return;
		
	# Mouse Held Down
	if ( event is InputEventMouseButton ) :
		if ( event.button_index == MOUSE_BUTTON_LEFT ):
			isLeftMouseDown = event.pressed;
		
	# Mouse Dragging && Mouse Held Down
	elif ( event is InputEventMouseMotion && isLeftMouseDown ) :
		
		# Only Y-axis rotation
		rotationSpeed += event.relative.x * dragStrength;
	
func process_states( delta : float ) -> void :
	
	if ( !isActive || !followPoint ) :
		return;
		
	# Move & Rotate Towards Center Point
	if ( !isFocused ) :
		rotation.x = lerp( rotation.x, initialLocalRotationX, moveSpeed * delta );
		global_position = global_position.lerp( followPoint, moveSpeed * delta );
		global_rotation.y += 1.5 * delta;
		rotationSpeed = 0; # -> Refers To Mouse Drag Rotation
	
	# Move Towards Camera Object Focus Point & Rotate Towards Camera Position
	else :
		rotation.x = lerp( rotation.x, 0.0, moveSpeed * delta );
		isInDraggableRange = global_position.distance_to( galleryManager.focusedNode.global_position ) <= 0.001;
		# If Far From Camera, Move & Rotate In
		if ( !isInDraggableRange ) :
			face_toward_camera( delta );
			global_position = global_position.lerp( galleryManager.focusedNode.global_position, moveSpeed * delta );
		# If Close Enough, Stop & Allow Mouse Drag Rotation
		else :
			if ( abs( rotationSpeed ) > 0.0001 ) :
				rotate( rotationAxis, rotationSpeed * delta );
				rotationSpeed = lerp( rotationSpeed, 0.0, deceleration * delta );
			else:
				rotationSpeed = 0.0;
			
# Update Where Mead Mesh Is Facing Toward
func face_toward_camera( delta: float ) -> void:
	
	var rotationSpeedFacing: float = 8.0;
	
	var lookAtPoint : Vector3;
	var targetTransform: Transform3D; 
	
	lookAtPoint = galleryManager.camera3d.global_position + Vector3( 0, -0.55, 0 );
		
	targetTransform = mesh.global_transform.looking_at( lookAtPoint, Vector3.UP );
		
	var targetRotation: Quaternion = targetTransform.basis.get_rotation_quaternion();
	targetRotation *= Quaternion( Vector3.UP, PI );
	
	var currentRotation: Quaternion = mesh.global_transform.basis.get_rotation_quaternion();
	
	var nextRotation: Quaternion = currentRotation.slerp(
		targetRotation,
		rotationSpeedFacing * delta );
	
	mesh.global_rotation = nextRotation.get_euler();
	
func set_new_position_node( node : Node3D ) -> void :
	followPoint = node.global_position;
	

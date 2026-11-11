extends HoverableObject
class_name Snack

enum BottleState {
	IDLE,
	INSPECTED,
}
var currentState : BottleState = BottleState.IDLE;

@export var galleryManager : GalleryManager;
@export var camera3D : Camera3D;
@export var idleNode : Node3D;
@export var focusedNode : Node3D;

var rotationAxis : Vector3 = Vector3.UP;
var dragStrength : float = 0.05;
var deceleration : float = 3.0;
var rotationSpeed : float = 0.0;
var moveSpeed : float = 8.0;
var moveSpeedPlus : float = 0.0;

var isLeftMouseDown : bool = false;
var isInDraggableRange : bool = false;


func init() -> void :
	
	super();
	visible = false;
	isActive = false;
	
func update( delta : float ) -> void :
	
	super( delta );
	process_states( delta )
	
			
# Get Mouse Input For Dragging
func _input( event ) :
	
	if ( currentState != BottleState.INSPECTED || !isInDraggableRange ) :
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
	
	match currentState :
		
		# Move & Rotate Towards Snack Box
		BottleState.IDLE :
			
			moveSpeedPlus = 0;
			isActive = false;
			global_position = global_position.lerp( idleNode.global_position, moveSpeed * delta );
		
		# Move Towards Camera Object Focus Point & Rotate Towards Camera Position
		BottleState.INSPECTED :
			
			isActive = false;
			moveSpeedPlus = 0;
			isInDraggableRange = global_position.distance_to( focusedNode.global_position ) <= 0.001;
			
			# If Far From Camera, Move & Rotate In
			if ( !isInDraggableRange ) :
				face_toward_camera( delta );
				global_position = global_position.lerp( focusedNode.global_position, moveSpeed * delta );
			
			# If Close Enough, Stop & Allow Mouse Drag Rotation
			else :
				
				if ( abs( rotationSpeed ) > 0.0001 ) :
					rotate( rotationAxis, rotationSpeed * delta );
					rotationSpeed = lerp( rotationSpeed, 0.0, deceleration * delta );
				else:
					rotationSpeed = 0.0;
			
# Update Where Mead Mesh Is Facing Toward
func face_toward_camera( delta: float ) -> void:
	
	#var cameraUpVector : Vector3 = cameraManager.camera3D.transform.basis.z;
	
	var rotationSpeedFacing: float = 8.0;
	
	var lookAtPoint : Vector3;
	var targetTransform: Transform3D; 
	
	lookAtPoint = camera3D.global_position;
		
	targetTransform = mesh.global_transform.looking_at( lookAtPoint, Vector3.UP );
		
	var targetRotation: Quaternion = targetTransform.basis.get_rotation_quaternion();
	targetRotation *= Quaternion( Vector3.UP, PI );
	
	var currentRotation: Quaternion = mesh.global_transform.basis.get_rotation_quaternion();
	
	var nextRotation: Quaternion = currentRotation.slerp(
		targetRotation,
		rotationSpeedFacing * delta );
	
	mesh.global_rotation = nextRotation.get_euler();
	

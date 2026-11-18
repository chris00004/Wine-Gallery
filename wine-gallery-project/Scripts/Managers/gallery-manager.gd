extends Node
class_name GalleryManager

@export var camera3d : Camera3D;
@export var mouseManager : MouseManager;
@export var uiManager : UIManager;

@export var focusedNode : Node3D;
@export var middleNode : Node3D;
@export var backMiddleNode : Node3D;
@export var sideNodeLeft : Node3D;
@export var sideNodeRight : Node3D;
@export var backNodeLeft : Node3D;
@export var backNodeRight : Node3D;

@export var nysWines : Array[ WineBottle ];
var currentWines : Array[ WineBottle ];
var currentIndex : int = 0;
var hoveredBottle : WineBottle;
var currentBottle : WineBottle;
var isFocused : bool = false;

func _ready() -> void :
	init();

func _physics_process( delta: float ) -> void :
	update( delta );
	
func init() -> void :
	if( !camera3d ) :
		return;
	if ( nysWines ) :
		for bottle in nysWines :
			bottle.init();
	mouseManager.init();
	
func update( delta : float ) -> void :
	
	if ( nysWines ) :
		for bottle in nysWines :
			bottle.update( delta );
		
	if( Input.is_key_pressed( KEY_0 ) ) :
		change_wine_array( nysWines );

	if ( mouseManager.currentHoveredNode is WineBottle ) :
		hoveredBottle = mouseManager.currentHoveredNode;
		
	if ( hoveredBottle ) :
	
		if ( hoveredBottle == currentBottle ) :
			if ( Input.is_action_just_pressed( "LeftClick" ) && !isFocused && hoveredBottle.isHovered ) :
				hoveredBottle.isFocused = true;
				isFocused = true;
				
			elif ( Input.is_action_just_pressed( "RightClick" ) && hoveredBottle.isFocused ) :
				hoveredBottle.isFocused = false;
				isFocused = false;
				
		elif ( !isFocused ) :
			if ( Input.is_action_just_pressed( "LeftClick" ) && hoveredBottle.isHovered ) :
				set_current_wine( hoveredBottle );
			
		if ( hoveredBottle.isFocused ) :
			uiManager.cursorHSizePanel.mouse_default_cursor_shape = Control.CURSOR_HSIZE;
		else :
			uiManager.cursorHSizePanel.mouse_default_cursor_shape = Control.CURSOR_ARROW;
			
	mouseManager.update( delta );
		
func change_wine_array( array : Array[ WineBottle ] ) -> void :
	
	currentWines = array;
	currentIndex = 0;
	currentBottle = currentWines[ currentIndex ];
	uiManager.update_wine_information( currentBottle );
	shift_bottles();
		
			
func set_current_wine( newBottle : WineBottle ) -> void :
	
	if ( currentWines.is_empty() || !newBottle || newBottle == currentBottle ) :
		return;
		
	var nextIndex : int = get_wine_index( currentIndex + 1 );
	var prevIndex : int = get_wine_index( currentIndex - 1 );
	
	# If New Bottle Is Next On Right
	if ( newBottle == currentWines[ nextIndex ] ) :
		currentIndex = nextIndex;
		shift_bottles();
		currentBottle = newBottle;
		
	# If New Bottle Is Next On Left	
	elif ( newBottle == currentWines[ prevIndex ] ) :
		currentIndex = prevIndex;
		shift_bottles();
		currentBottle = newBottle;
		
	uiManager.update_wine_information( currentBottle );
		
	
func shift_bottles() -> void :
	
	var size : int = currentWines.size(); 
	
	var primaryNode : Node3D = middleNode;
	var secondaryNode : Node3D = sideNodeRight;
	var tertiaryNode : Node3D = backNodeRight;
	
	# If 3 bottles, re-route 3rd bottle to left spot
	if ( size < 4 ) :
		tertiaryNode = sideNodeLeft;
	
	for i in range( size ) :
		
		if ( i == currentIndex ) :
			currentWines[ get_wine_index( currentIndex ) ].set_new_position_node( primaryNode );
			print( "1" + currentWines[ get_wine_index( currentIndex ) ].to_string() );
		elif ( i == get_wine_index( currentIndex + 1 ) ) :
			currentWines[ get_wine_index( currentIndex + 1 ) ].set_new_position_node( secondaryNode );
			print( "2" + currentWines[ get_wine_index( currentIndex + 1 ) ].to_string() );
		elif ( i == get_wine_index( currentIndex + 2 ) ) :
			currentWines[ get_wine_index( currentIndex + 2 ) ].set_new_position_node( tertiaryNode );
			print( "3" + currentWines[ get_wine_index( currentIndex + 2 ) ].to_string() );
		elif ( i == get_wine_index( currentIndex - 1 ) ) :
			currentWines[ get_wine_index( currentIndex - 1 ) ].set_new_position_node( sideNodeLeft );
			print( "BackRight" + currentWines[ get_wine_index( currentIndex - 1 ) ].to_string() );
		elif ( i == get_wine_index( currentIndex - 2 ) ) :
			currentWines[ get_wine_index( currentIndex - 2 ) ].set_new_position_node( backNodeLeft );
			print( "BackLeft" + currentWines[ get_wine_index( currentIndex - 2 ) ].to_string() );
		else :
			currentWines[ i ].global_position = middleNode.global_position + Vector3( 0, 0, -12 );
			print( "OffScreen" + currentWines[ i ].to_string() );
			
func get_wine_index( index : int ) -> int :
	
	var endIndex : int = currentWines.size() - 1;
	
	if ( index > endIndex ) :
		return index - currentWines.size();
		
	if ( index < 0 ) :
		return currentWines.size() + index;
		
	return index;

extends Node
class_name GalleryManager

@export var camera3d : Camera3D;
@export var mouseManager : MouseManager;
@export var uiManager : UIManager;

@export var focusedNode : Node3D;
@export var middleNode : Node3D;
@export var sideNodeLeft : Node3D;
@export var sideNodeRight : Node3D;

@export var nysWines : Array[ WineBottle ];
var currentWines : Array[ WineBottle ];
var currentIndex : int = 0;
var hoveredBottle : WineBottle;
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
	
		if ( Input.is_action_just_pressed( "LeftClick" ) && hoveredBottle.isHovered && !isFocused ) :
			hoveredBottle.isFocused = true;
			isFocused = true;
			
		elif ( Input.is_action_just_pressed( "RightClick" ) && hoveredBottle.isFocused) :
			hoveredBottle.isFocused = false;
			isFocused = false;
			
		if ( hoveredBottle.isFocused ) :
			uiManager.cursorHSizePanel.mouse_default_cursor_shape = Control.CURSOR_HSIZE;
		else :
			uiManager.cursorHSizePanel.mouse_default_cursor_shape = Control.CURSOR_ARROW;
			
	mouseManager.update( delta );
	print( mouseManager.currentHoveredNode )
		
func change_wine_array( array : Array[ WineBottle ] ) -> void :
	
	currentWines = array;
	currentIndex = 0;
	
	for i in range( currentWines.size() ) :
		if ( i == 0 ) :
			currentWines[ 0 ].set_new_position_node( middleNode );
		elif ( i == 1 ) :
			currentWines[ 1 ].set_new_position_node( sideNodeRight );
		elif ( i == currentWines.size() - 1 ) :
			currentWines[ currentWines.size() - 1 ].set_new_position_node( sideNodeLeft );
			
		

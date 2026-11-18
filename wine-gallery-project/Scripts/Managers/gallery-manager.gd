extends Node
class_name GalleryManager

enum Region {
	NONE = 0,
	NYS = 1,
}

var currentRegion : Region = Region.NONE;

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

var wineRegionArraysList : Array;
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
	wineRegionArraysList = [ nysWines ];
	mouseManager.init();
	uiManager.init();
	
func update( delta : float ) -> void :
	
	var optionSelected : int = uiManager.regionSelection.selected;
	if( optionSelected != int( currentRegion ) ) :
		if ( optionSelected < Region.size() && optionSelected > -1 ) :
			change_wine_region( uiManager.regionSelection.selected as Region );
			uiManager.wineInfoPanels.visible = true;
		
	if ( currentWines ) :
		for bottle in currentWines :
			bottle.update( delta );

	if ( mouseManager.currentHoveredNode is WineBottle ) :
		hoveredBottle = mouseManager.currentHoveredNode;
	
	if ( !isFocused ) :
		if ( hoveredBottle ) :
			if ( hoveredBottle == currentBottle ) :
				if ( Input.is_action_just_pressed( "LeftClick" ) && !isFocused && hoveredBottle.isHovered ) :
					hoveredBottle.isFocused = true;
					isFocused = true;
					uiManager.cursorHSizePanel.mouse_default_cursor_shape = Control.CURSOR_HSIZE;
					uiManager.exitFocusPrompt.visible = true;
					
			elif ( !isFocused ) :
				if ( Input.is_action_just_pressed( "LeftClick" ) && hoveredBottle.isHovered ) :
					set_current_wine( hoveredBottle );
				
		
	else :
		if ( Input.is_action_just_pressed( "RightClick" ) ) :
			currentBottle.isFocused = false;
			isFocused = false;
			uiManager.cursorHSizePanel.mouse_default_cursor_shape = Control.CURSOR_ARROW;
			uiManager.exitFocusPrompt.visible = false;
			

	mouseManager.update( delta );
		
func change_wine_region( region : Region ) -> void :

	if ( region == currentRegion ) :
		return;
		
	currentRegion = region;
	
	if ( !currentWines.is_empty() ) :
		shelve_bottles( currentWines );
		
	if ( currentRegion == Region.NONE ) :
		return;
		
	var array : Array[ WineBottle ] = wineRegionArraysList[ int( currentRegion ) - 1 ];
	print( array )
		
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

func shelve_bottles( bottles : Array[ WineBottle ] ) -> void :
	for bottle in bottles :
		bottle.global_position.y += 10;

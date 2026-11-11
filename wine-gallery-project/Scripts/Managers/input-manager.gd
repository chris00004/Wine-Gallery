extends Node
class_name InputManager

class InputStruct:
	var buffer : float = 0.1;
	var bufferCurrent : float = 0.0;
	var isActive : bool = false;
	var isHeld : bool = false;
	var isJustPressed : bool = false;
	var isJustReleased : bool = false;
	var isLocked : bool = false;

var actionUp = InputStruct.new();
var actionLeft = InputStruct.new();
var actionDown = InputStruct.new();
var actionRight = InputStruct.new();
var actionSprint = InputStruct.new();
var actionTurn = InputStruct.new();
var actionLeftClick = InputStruct.new();
var actionReturn = InputStruct.new();
var actionSteer = InputStruct.new();
var actionStart = InputStruct.new();
var actionSelect = InputStruct.new();

enum InputID {
	ACTION_UP,
	ACTION_LEFT,
	ACTION_DOWN,
	ACTION_RIGHT,
	ACTION_SPRINT,
	ACTION_TURN,
	ACTION_LEFT_CLICK,
	ACTION_RETURN,
	ACTION_STEER,
	ACTION_START,
	ACTION_SELECT
}

var inputMapRawString : Dictionary = {
	InputID.ACTION_UP : "Up",
	InputID.ACTION_LEFT : "Left",
	InputID.ACTION_DOWN : "Down",
	InputID.ACTION_RIGHT : "Right",
	InputID.ACTION_SPRINT : "ActionSprint",
	InputID.ACTION_TURN : "ActionTurn",
	InputID.ACTION_RETURN : "ActionReturn",
	InputID.ACTION_LEFT_CLICK : "ActionLeftClick",
	InputID.ACTION_STEER : "ActionSteer"
};

var inputMap : Dictionary = {
	InputID.ACTION_UP : actionUp,
	InputID.ACTION_LEFT : actionLeft,
	InputID.ACTION_DOWN : actionDown,
	InputID.ACTION_RIGHT : actionRight,
	InputID.ACTION_SPRINT : actionSprint,
	InputID.ACTION_TURN : actionTurn,
	InputID.ACTION_RETURN : actionReturn,
	InputID.ACTION_LEFT_CLICK : actionLeftClick,
	InputID.ACTION_STEER : actionSteer
};

# Input
var rawInput : Vector2; 
var inputDir : Vector3;
var inputAngle : float;
var inputAnglePrev : float;
var moveInput : bool = false;
var deadzone : float = 0.4;


func update( delta : float ) -> void :
	
	process_input_objects( delta );
	
	# Get Move Input
	var xAxis = int( actionRight.isHeld ) - int( actionLeft.isHeld );
	var yAxis = int( actionDown.isHeld ) - int( actionUp.isHeld );
	
	rawInput = Vector2( xAxis, yAxis ).normalized();
	moveInput = ( rawInput.length() > deadzone ); 
	
	inputAnglePrev = inputAngle;
		
	inputAngle = rad_to_deg( atan2( -rawInput.y, rawInput.x ) );
	
	if ( inputAngle < 0 ) :
		inputAngle += 360;
	
	inputDir = Vector3( rawInput.x, 0, rawInput.y );
	
func process_input_objects( delta : float ) -> void :
	
	for inputKey in inputMap :
		
		var input = inputMap [ inputKey ];
		
		if ( input.isLocked ) :
			input.isJustPressed = false;
			input.isJustReleased = false;
			input.isHeld = false;
			input.isActive = false;
			continue;

		input.isJustPressed = Input.is_action_just_pressed( inputMapRawString [ inputKey ] );
		input.isJustReleased = Input.is_action_just_released( inputMapRawString [ inputKey ] );
		input.isHeld = Input.is_action_pressed( inputMapRawString [ inputKey ] );
		
		input.bufferCurrent -= delta;
		if ( input.bufferCurrent < 0.0 ) :
			input.bufferCurrent = 0.0;
			
		input.isActive = input.bufferCurrent > 0.0;
		if ( Input.is_action_just_pressed( inputMapRawString [ inputKey ] ) && !input.isLocked ) :
			input.bufferCurrent = input.buffer;
			
func reset_buffer( inputKey : InputID ) :
	inputMap [ inputKey ].bufferCurrent = 0.0;
	
func lock_input( inputKey : InputID ) :
	inputMap [ inputKey ].isLocked = true;
	
func unlock_input( inputKey : InputID ) :
	inputMap [ inputKey ].isLocked = false;

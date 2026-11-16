extends Node3D
class_name HoverableObject

@export var mesh : MeshInstance3D;

var shaderMaterial : ShaderMaterial;
var outlineMaterial : ShaderMaterial;

var isActive : bool;
var isHovered : bool;
var isInHoverRange : bool;
@export var interactDistance : float = 3.4;
@export var outlineSize : float = 0.03;
@export var isDefault : bool = true;

func init() -> void :
	
	isActive = true;
	isHovered = false;
	isInHoverRange = false;
	
	if ( isDefault ) :
		# Get Access To Applied Shader Material
		shaderMaterial = mesh.get_active_material( 0 );
		outlineMaterial = shaderMaterial.next_pass;
	
func update( delta : float ) -> void :
	
	handle_if_hovered( outlineSize );

# Show Outline If Mouse Hovering
func handle_if_hovered( outline : float ) -> void :
	
	if ( !shaderMaterial || !outlineMaterial || !isDefault ) :
		#print("hoverable has no shader ref");
		return;
	
	if ( isHovered && isInHoverRange && isActive ) : 
		
		# Set Outline
		outlineMaterial.set_shader_parameter( "outlineSize", outline );
	else :
		
		# Disable Outline
		outlineMaterial.set_shader_parameter( "outlineSize", 0.0 );

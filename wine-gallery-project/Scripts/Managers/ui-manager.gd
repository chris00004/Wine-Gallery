extends Node
class_name UIManager

@export var regionSelection : OptionButton;

@export var producerlabel : Label;
@export var informationlabel : Label;

@export var cursorHSizePanel : Panel;
@export var linkButton : LinkButton;

func update_wine_information( bottle : WineBottle ) -> void :
	
	producerlabel.text = bottle.producerString;
	
	informationlabel.text = "Grape: " + bottle.grapeString \
							+ "\nCountry: " + bottle.countryString \
							+ "\nRegion: " + bottle.regionString \
							+ "\nVintage: " + bottle.vintageYearString \
							+ "\nPrice: $" + bottle.priceString \
							+ "\nAlc. by Vol.: " + bottle.alcPercentageString + "%" \
							;
							
	linkButton.visible = false;
	linkButton.uri = "";
	
	if ( !bottle.websiteLinkString.is_empty() ) :
		linkButton.visible = true;
		linkButton.uri = bottle.websiteLinkString;
		
	

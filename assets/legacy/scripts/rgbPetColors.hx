import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;
import String;

// hi this is kim, this script was made by ASHLEY and edited by LOGGO and ORBYY, thank you!
public var petRGB:FlxRuntimeShader = null;

/**
	* Since the RGB pets default to Boyfriend's health icon color, some colors (like yellowplayable and amongbf) would be ugly/inaccurate to how they are in Among Us. 
	- This is how it works:
	```haxe
	"skinname" => [lightercolor, darkercolor]
	```
	
	(only for compat purposes and because im lazy to move all of these now but use flags instead)
**/
public var overwriteColors:Map<String, Array<FlxColor>> = [
	'bf-ghost' => [0x66FFFF, 0x50A5EB],
	'amongbf' => [0x66FFFF, 0x50A5EB],
	'greenp' => [0xFF00661A, 0xFF003E37],
	'yellowplayable' => [0xFFFFD452, 0xFFE0893B],
	'whitep' => [0xFFE9E4F4, 0xFF7278B6],
	'blackp' => [0xFF381B51, 0xFF200A1E],
	'maroonplayable' => [0xFF6B2B3C, 0xFF440D37],
	'pinkplayable' => [0xFFFD42AD, 0xFF9E01B9],
	'fall-guy' => [0xFFFF6699, 0xFFCC3399],
	'minigrey' => [0xFF59587A, 0xFF282C4F],
	'noob49player' => [0xFF59587A, 0xFF282C4F],
	'LIMEGREENPlayable' => [0xFF66FF65, 0xFF009A65],
	'tuesdayplayable' => [0xFFFF6770, 0xFFC6377B],
	'chefplayable' => [0xFFFF8E38, 0xFFFB4C3D],
	'whitewho' => [0xFFFF9933, 0xFFFF4040],
	'whitemad' => [0xFFFF9933, 0xFFFF4040],
	'dripbf' => [0xFF9933FF, 0xFF3E35B1],
	'pip' => [0xFFFF3535, 0xFF8A1843],
	'pip_evil' => [0xFFFF3535, 0xFF8A1843],
	'pretender' => [0xFFE64499, 0xFF760386],
	'detectiveplayer' => [0xFF342F43, 0xFF15141A],
	'blake' => [0xFF342F43, 0xFF15141A],
	'bobby' => [0xFF1F0F89, 0xFF19123E],
	'bfblack' => [0xFF2B2C3C, 0xFF1A182E],
	'shit' => [0xFF7D4831, 0xFF5F1B37],
	'amongbfweird' => [0xFFC93E3E, 0xFF80254D]
];

/**
	* The variable that checks if `rgbPets` contains `pet.curPet`
**/
var hasRGBpet:Bool = false;

function applyPetRGB(pet:Pet)
{
	if (!pet.getFlag('rgb')) return; // WHAT DO YOU MEAN WE DONT EVEN HAVE AN RGB PET ON
	if (!pet.isAnimate)
	{
		trace('RGB pet ${pet.curPet} must be a texture atlas');
		return;
	}
	
	if (petRGB == null)
	{
		var frag:String = Paths.getTextFromFile('shaders/amongRgb.frag');
		petRGB = new FlxRuntimeShader(frag);
		petRGB.setFloatArray('green', [96 / 255, 208 / 255, 1]);
		petRGB.setFloat('visor', 1);
	}
	
	for (layer in pet.timeline.layers)
	{
		layer.forEachFrame(function(frame) {
			for (element in frame.elements)
				element.shader = petRGB;
		});
	}
	pet.useRenderTexture = true;
}

function onCreatePost()
{
	applyPetRGB(pet);
	pet.onChange.add(applyPetRGB);
	
	reloadPetRGB(boyfriend);
}

/**
	* converts `FlxColor` into an array of `R, G, B` divided by 255 for the shader support
**/
function convertColor(col:FlxColor = 0xFFFFFF):Array<Float> {
	var colorArray:Array<Float> = [
		FlxColor.getRed(col) / 255,
		FlxColor.getGreen(col) / 255,
		FlxColor.getBlue(col) / 255
	];
	return colorArray;
}

/**
	* Reloads the color shader depending on `based.healthColour`
	```haxe
	reloadPetRGB(boyfriend);
	```
**/
public function reloadPetRGB(?based:Character = boyfriend) {
	if (petRGB == null) return;
	
	if (overwriteColors.exists(based.curCharacter))
	{
		// if it has handmade colors assigned to it, get them from the map.
		var color:Array<Float> = overwriteColors.get(boyfriend.curCharacter);
		petRGB.setFloatArray('red', convertColor(color[0]));
		petRGB.setFloatArray('blue', convertColor(color[1]));
	}
	else if (based.hasFlag('rgbPetColor'))
	{
		var color:Array<Int> = [for (color in based.getFlag('rgbPetColor')) Std.isOfType(color, String) ? Std.parseInt(color) : color];
		petRGB.setFloatArray('red', convertColor(color[0]));
		petRGB.setFloatArray('blue', convertColor(color[1]));
	}
	else
	{
		// else, we just automate it.
		var color:FlxColor = convertColor(based.healthColour);
		petRGB.setFloatArray('red', color);
		petRGB.setFloatArray('blue', [color[0]/2, color[1]/2, color[2] / 2 + 0.2]);
	}
}
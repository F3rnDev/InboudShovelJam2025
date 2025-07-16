shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(UV.x + UV.y > progress * 2.0)
	{
		if(!reverse)
		{
			discard;
		}
	}
	else if(reverse)
	{
		discard;
	}
}

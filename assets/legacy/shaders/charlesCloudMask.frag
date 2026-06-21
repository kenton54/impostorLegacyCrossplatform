#pragma header

uniform sampler2D u_mask;

uniform vec2 u_mask_size;

uniform vec2 u_mask_offset;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    
    vec4 tex = flixel_texture2D(bitmap, uv);
    
    vec2 mask_uv = (openfl_TextureCoordv * openfl_TextureSize) / u_mask_size;
    
    mask_uv += u_mask_offset;
    
    mask_uv.x = fract(mask_uv.x);
    
    if (mask_uv.y < 0. || mask_uv.y >= 1.)
    {
        gl_FragColor = tex;
    }
    else
    {
        vec4 mask_layer = flixel_texture2D(u_mask, mask_uv);
    	
    	if (mask_layer.a == 0. || tex.a == 0.)
    	{
    		gl_FragColor = tex;
    	}
    	else
    	{
        	gl_FragColor = vec4(mix(tex.rgb / tex.a, mask_layer.rgb / mask_layer.a, mask_layer.a) * tex.a, tex.a);
    	}
    }
}

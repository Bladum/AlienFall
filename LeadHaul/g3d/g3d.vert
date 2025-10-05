// written by groverbuger for g3d
// may 2021
// MIT license

// this vertex shader is what projects 3d vertices in models onto your 2d screen

uniform mat4 projectionMatrix; // handled by the camera
uniform mat4 viewMatrix;       // handled by the camera
uniform mat4 modelMatrix;      // models send their own model matrices when drawn
uniform bool isCanvasEnabled;  // detect when this model is being rendered to a canvas

extern vec4 fillColor;
extern vec2 textureDimensions;

varying vec3 worldPos;
varying vec4 relativeWorldPosition;

#ifdef VERTEX

	vec4 position(mat4 transformProjection, vec4 vertexPosition) {
		relativeWorldPosition = projectionMatrix * viewMatrix * modelMatrix * vertexPosition;
		
		// for some reason models are flipped vertically when rendering to canvases
		// so we need to detect when this is being rendered to a canvas, and flip it back
		if (isCanvasEnabled) {
			relativeWorldPosition.y *= -1;
		}

		return relativeWorldPosition;
	}
#endif

#ifdef PIXEL
    vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
    {
        vec4 texcolor = Texel(tex, texcoord);
		
		// discard see-through bits
		if (texcolor.a < .001) { discard; }
		
		// calc color
		vec4 col = texcolor;
		vec3 fCol = vec3(fillColor.r,fillColor.g,fillColor.b);
		
		if ( fillColor.a > 0 ) {	//fill color
			fCol = fCol * fillColor.a;
			
			return vec4( fCol.r + col.r, fCol.g + col.g, fCol.b + col.b, 1 );
		}
		
		// return the end color
        return col;
    }
#endif
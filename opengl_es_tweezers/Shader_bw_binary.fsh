
//
//  Shader.fsh
//  Untitled
//
//  Created by Richard Bowman on 23/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

precision mediump float;
uniform mediump int outputType;


varying vec4 colorVarying;

const vec4 twhite = vec4(1.0,1.0,1.0,0.0);
const vec4 alpha = vec4(0.0,0.0,0.0,1.0);

void main()
{
//convert (re,im,abs) to black->white, using an approximation
	float r = colorVarying.x; 
	float i = colorVarying.y; 
	float a = 1.0;
	float aa= sqrt(r*r+i*i);
	//float gray=((0.125*i/aa+.25)*sign(r) + 0.125*(sign(r) - r/aa)*sign(i) +0.375);
    //gray=step(0.5,(gray-0.5)*2.2); //bodge to make it work better with CC SLMs
    float gray = clamp(sign(r),0.0,1.0);
	gl_FragColor = vec4(gray,gray,gray,1.0);
	//The approximation is that we go from 0->0.25, 0.25->0.5, etc. in each quadrant of complex space, so we are mapping the unit disc onto a unit square- it's good enough...
}

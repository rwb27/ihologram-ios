
//
//  Shader.fsh
//  Untitled
//
//  Created by Richard Bowman on 23/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

precision mediump float;

varying vec4 colorVarying;

void main()
{//convert (re,im,abs) to rgb
	float r = colorVarying.x; 
	float i = colorVarying.y; 
	float a = colorVarying.z;
	float aa= sqrt(r*r+i*i);
	
	gl_FragColor = vec4(clamp(vec3(.866*r-.5*i,-.866*r-.5*i,i)/aa/1.5+0.6667,0.0,1.0)*aa,1.0); //final aa was just a, makes little difference
	
	//define 3 axes at 2pi/3 intervals, such that each colour channel goes from 0 to 1 along those axes (in complex space).
	//this does the nice phase->rainbow thing with *no trig functions*
}

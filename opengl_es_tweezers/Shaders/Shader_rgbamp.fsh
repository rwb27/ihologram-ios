
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

/*
uniform vec4 spots[10];
const vec2 size=vec2(4,4); //because of limited precision, xy and f are in mm
const float f=1.6;
const float k=90.0; //to help with precision, k is per micron not per m
uniform int n;
*/
const float pi=3.141;
const vec4 white = vec4(1.0,1.0,1.0,1.0);

void main()
{
//  Vertex Shader outputs colour
/*	float minc= min(colorVarying.r,min(colorVarying.g,colorVarying.b)); //one channel should always be zero
	float maxc= max(colorVarying.r,max(colorVarying.g,colorVarying.b)); //one channel should always be zero
	gl_FragColor = (colorVarying-minc)/(maxc-minc);//*/

//convert (re,im,abs) to rainbow
/*	mediump float phase = atan(colorVarying.x,colorVarying.y);
	lowp float amplitude=1.0;
	if(outputType==1) amplitude=colorVarying.z;
	
	gl_FragColor = vec4(amplitude*clamp(2.0-(abs(mod((phase+3.0*pi)-rainbow,2.0*pi)-pi))*(3.0/pi),0.0,1.0),1.0);//*/

//convert (re,im,abs) to rgb, faster but not as pretty
	float r = colorVarying.x; 
	float i = colorVarying.y; 
	float a = 1.0;
	float aa= sqrt(r*r+i*i);
	if(outputType==1) a=colorVarying.z; //actual amplitude
	
	gl_FragColor = clamp(vec4(.866*r-.5*i,-.866*r-.5*i,i,1.0)/aa+0.5,0.0,1.0)*a;
	//vec4 colout = clamp(vec4(.866*r-.5*i,-.866*r-.5*i,i,1.0)/aa+0.5,0.0,1.0)*a;
	//vec4 bwout = white*(0.125*i/aa*sign(r) - 0.125*r/aa*sign(i) +0.375 + 0.25*sign(r)+0.125*sign(i)*sign(r));
	//gl_FragColor = (outputType==2 ? bwout : colout );//*/
//
//	if(outputType==1) gl_FragColor = vec4(colorVarying.z*clamp(2.0-(abs(mod((phase+3.0*pi)-rainbow,2.0*pi)-pi))*(3.0/pi),0.0,1.0),1.0);
//	if(outputType==2) gl_FragColor = vec4(vec3(1.0,1.0,1.0)*(phase/pi+1.0)/2.0,1.0);
}

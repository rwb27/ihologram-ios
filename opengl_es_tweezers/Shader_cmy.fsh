
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
	float aa= sqrt(r*r+i*i);
	
	gl_FragColor = clamp(vec4(.866*r-.5*i,-.866*r-.5*i,i,1.0)/aa/1.5+0.6667,0.0,1.0);
	
	//define 3 axes at 2pi/3 intervals, such that each colour channel goes from 0 to 1 along those axes (in complex space).
	//this does the nice phase->rainbow thing with *no trig functions*
	// phase 0--1--2--3--4--5--6 (where 0=0+i and pi/2=1+0i)
	// red    // // 11 11 \\ \\
	// green  11 11 \\ \\ // //
	// blue   \\ \\ // // 11 11
	// this is the same as r-b-g- but the DC bias changes.  for rgb, the range of each component is 2, and we add 0.5
	// and clamp to [0,1].  To do the same for cmy, we need to add 
}

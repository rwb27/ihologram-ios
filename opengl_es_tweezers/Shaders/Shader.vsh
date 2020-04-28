//
//  Shader.vsh
//  opengl_es_tweezers
//
//  Created by Richard Bowman on 22/07/2010.
//  Copyright University of Glasgow 2010. All rights reserved.
//

attribute vec4 position;
//attribute vec4 color;

varying vec4 colorVarying;

precision mediump float;
precision mediump int;

uniform vec4 spots[10];
uniform vec2 slmsize; //because of limited precision, xy and f are in mm
const float f=1.0;
const float k=3.14; //to help with precision, k is per micron not per m
                    //here, we set k to pi, so that if slmsize is 1 we get a maximum of 2pi phase ramp across the aperture.
                    //slmsize will probably be set to meshResolution/5.
uniform int n;
uniform int meshResolution;

const float pi=3.141;
const vec4 rainbow = vec4(4.0/3.0*pi,2.0/3.0*pi,0,0);
const vec4 twhite = vec4(1,1,1,0);


void main()
{

	float phase=0.0, amplitude=0.0;
	vec2 xy=(position.xy)*slmsize;      //in this case, position ranges from -1 to +1 over the CENTRAL SQUARE (i.e. they will exceed 1 outside the square)
	float phi=atan(xy.x,xy.y);
	vec4 pos=vec4(xy/f,1.0-dot(xy/f,xy/f/float(meshResolution))/2.0,phi/k); //the division by meshResolution is to stop things going crazy numerically...
	
	float totalr=0.0, totali=0.0, totala=0.0;
	
	int j=0;
	for(int i=0; i<n; i++){
		j=i;
		amplitude=1.0;
		phase=k*dot(spots[i],pos);
		totalr += amplitude*sin(phase);
		totali += amplitude*cos(phase);
		totala += amplitude;
	}//*/
	totalr/=totala;
	totali/=totala;
	colorVarying=vec4(totalr,totali,sqrt(totalr*totalr+totali*totali),1.0);//*/
		
/*	phase=atan(totalr,totali);
	colorVarying=clamp(2.0-(abs(mod(twhite*(phase+3.0*pi)-rainbow,2.0*pi)-pi))*(3.0/pi),0.0,1.0);//*/
    gl_Position = position;
}

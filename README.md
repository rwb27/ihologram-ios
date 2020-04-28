# ihologram-ios
A digital holography app for iOS devices that demonstrates the "direct superposition" method of generating multi-spot optical tweezers.

This was code I wrote during my PhD, from 2008-12.  It has been more or less unmaintained since, and will need some renovating before it runs on modern iOS devices.  

If anyone would like to take it on, you're welcome.  It's Copyright Richard Bowman 2012, released under GNU General Public License v3.

## How does it work
The user interface is very simple - a number of "bubbles" (representing silica microspheres) are placed on the screen, and can be dragged around.  They can be pinched to change their size (which represents Z motion) or twisted to add helical charge to the associated spot.  An OpenGL ES shader program is then used to calculate a digital hologram that would, in the far field, produce one focused spot at the position of each particle.  This can be caluclated analytically, as one plane wave per spot.

The calculation is done over a coarse mesh, a few hundred points across.  Complex values are calculated for each vertex in the mesh using a "vertex shader" and stored as the colour of each vertex.  A "fragment shader" then runs on each pixel, using the interpolated complex values, and converts the complex number into a colour, using one of a few different complex-amplitude-to-colour methods.

## Setting up development
Sadly my mac died a while back, so I can't verify this even compiles.  However, it's an xcode project targeting iOS, so you'll need a mac and, if you want to test on actual devices, an Apple Development Programme license.  Personally, I think I'd like to see this ported to a web app, using WebGL to render in a canvas.  That would not require any fees, could be done cross-platform, and would be much more useful all round.

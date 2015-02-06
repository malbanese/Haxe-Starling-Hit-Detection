package com.cykon.haxe.movable.circle;

/**
  * This class is meant to represent a simple circular object.
  * Velocities can be applied to it, and it will move based off
  * of it's vx and vy.
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */
 
import com.cykon.haxe.movable.Hit;
import com.cykon.haxe.movable.line.Line;
import com.cykon.haxe.cmath.Vector;
import com.cykon.haxe.util.VectorDisplay;
import starling.textures.Texture;
import starling.display.Shape;

class Circle extends starling.display.Image {

	var radius:Float;	// Circle radius
	var vx:Float = 0;	// X Velocity
	var vy:Float = 0;	// Y Velocity
	var ax:Float = 0;  	// X Acceleration
	var ay:Float = 0;	// Y Acceleration
	
	var processingHit:Bool = false; // Tells the updateVelocity method whether we can move or not
	var hitVector:Vector;	   		// The normal vector representing a wall which was hit
	var leftoverMag:Float = 0; 		// The leftover magnitude from the last hit;
	var massMod = 1.0;		   		// Modifier to change mass by...
	
	public function setProcessingHit(processing:Bool){
		processingHit = processing;
	}
	
	public function isProcessingHit() : Bool {
		return processingHit;
	}
	
	/** Reterns whether or not there is leftoverMag from a hit */
	public function hasLeftOverMag() : Bool{
		return (leftoverMag != 0);
	}
	
	/** Return the X location of this (note: it's the center of the circle) */
	public function getX() : Float{
		return x + radius;
	}
	
	/** Return the Y location of this (note: it's the center of the circle) */
	public function getY() : Float{
		return y + radius;
	}
	
	/** Return the vx of this */
	public function getVX() : Float{
		return vx;
	}
	
	/** Return the vy of this */
	public function getVY() : Float{
		return vy;
	}
	
	/** Return the vxy in velocity format */
	public function getVelVector() : Vector{
		return new Vector(vx,vy);
	}
	
	/** Return the radius of this */
	public function getRadius() : Float{
		return radius;
	}
	
	/** Returns the mass of this object */
	public function getMass() : Float {
		return Math.PI * radius * radius * massMod;
	}
	
	/** Set the density of the mass of this object */
	public function setMassMod(massMod:Float){
		this.massMod = massMod;
	}
	
	/** Set the location of the circle, (note: this is in relation to the CENTER of the circle) */
	public function setLoc(x:Float, y:Float){
		this.x = x - radius;
		this.y = y - radius;
	}
	
	/** Gets the magnitude of the circle's velocities */
	public function getMag():Float{
		return Math.sqrt(vx*vx+vy*vy);
	}
	
	/** Set the velocities of the circle */
	public function setVelocity(vx:Float, vy:Float){
		this.vx = vx;
		this.vy = vy;
	}
	
	/** Set the acceleration of the circle */
	public function setAcceleration(ax:Float, ay:Float){
		this.ax = ax;
		this.ay = ay;
	}
	
	/** Applies the acceleration of the circle to it's velocities */
	public function applyAcceleration():Bool{
		if(processingHit)
			return false;
		
		this.vx += ax;
		this.vy += ay;
		return true;
	}
	
	/** Applies the velocities of the circle to the x & y coordinates */
	public function applyVelocity(modifier:Float):Bool{
		leftoverMag = 0;
		
		if(processingHit)
			return false;

		var movVector = new Vector(vx,vy).multiply(modifier);
		if(leftoverMag <= 0)
			movVector = new Vector(vx,vy).multiply(modifier);
		else
			movVector = new Vector(vx,vy).normalize().multiply(leftoverMag*modifier);
		
		if(Math.isNaN(movVector.getMag())){
			movVector.vx = movVector.vy = 0;
		}
		
		leftoverMag = 0;
		x += movVector.vx;
		y += movVector.vy;
		
		// Apply acceleration
		this.vx += ax;
		this.vy += ay;
		
		return true;
	}
	
	private function simpleSort(a:Float,b:Float):Int{
		if(a < b) return -1;
		if(a > b) return 1;
		return 0;
	}
	
	public function boundingVectorHit( circle : Circle, modifier : Float = 1.0 ):Bool{
		var xBound = [this.getX(), this.getX() + this.vx*modifier];
		var yBound = [this.getY(), this.getY() + this.vy*modifier];
		
		var XBound = [circle.getX(), circle.getX() + circle.vx*modifier];
		var YBound = [circle.getY(), circle.getY() + circle.vy*modifier];
	
		xBound.sort(simpleSort);  	yBound.sort(simpleSort);
		XBound.sort(simpleSort);  	YBound.sort(simpleSort);
		
		return !(XBound[0] > xBound[1]
			  || XBound[1] < xBound[0]
		      || YBound[0] > yBound[1]
			  || YBound[1] < yBound[0]);
	}
	 
	
	
	/** Test if this circle has collided with a line */
	public function lineHit( line : Line, modifier : Float = 1.0 ): Hit<Line> {
		// No movement = no need to compute
		if(this.vx == 0 && this.vy == 0)
			return null;
		
		var thisVector = new Vector(this.vx,this.vy).multiply(modifier);
		
		// Get the direct vector between this and a point on the line
		var pointVector = Vector.getVector(this.getX(), this.getY(), line.getP1().x, line.getP1().y);
		
		// Preliminary check to make sure that the circle is going towards the line
		var normVector = line.getNorm();
		if(normVector.dot(pointVector) >  0){
			normVector = normVector.getOpposite();
		}
		
		// Define the closest vector to work with
		var closestVector = normVector.clone();
		
		// In this case, the circle is moving away from the line
		var movingAway = false;
		if(closestVector.dot(thisVector) >= 0){
			movingAway = true;
		}
		
		// Get the closest vector between the circle and the line
		var closestMag = closestVector.multiply(closestVector.dot(pointVector)).getMag();
		
		
		// The circle is moving away from the line, and we are more than radius away
		if(movingAway && closestMag > radius)
			return null;
			
		// Get the closest vector in regards to the circle's velocity
		closestVector.normalize().multiply( closestVector.dot(thisVector) );
		
		// Get the hit ratio, to correct thisVector with
		var hitRatio = (closestMag - radius) / closestVector.getMag();
		
		// We have a hit, but still need to check if we hit within the line's bounds
		if(hitRatio <= 1.0){
			// New (x,y) positions
			var nx = getX() + vx*hitRatio*modifier;
			var ny = getY() + vy*hitRatio*modifier;
			
			// Vectors from each end point to the circle
			var pv1 = Vector.getVector( nx, ny, line.getP1().x, line.getP1().y );
			var pv2 = Vector.getVector( nx, ny, line.getP2().x, line.getP2().y );
			
			// Vectors are in the same direction... we are outside of the line and need to check endpoints
			if(pv1.dot(pv2) > 0){
				// Select the closest point to perform a hit check against
				var point = (pv1.getMag() < pv2.getMag()) ? line.getP1() : line.getP2();
				closestVector = Vector.getVector( getX(), getY(), point.x, point.y );
				
				if(closestVector.dot(thisVector) < 0)
					return null;
					
				var newVector = thisVector.clone().normalize();
				newVector.multiply( newVector.dot(closestVector) );
				
				// Find the distance when the circle will be closest to the point
				var dotMag = Math.sqrt( closestVector.getMag()*closestVector.getMag() - newVector.getMag()*newVector.getMag() );
				
				var radius = this.radius + 0.1; // A little hack lets us avoid nasty fpoint rounding errors
				
				// Hit is impossible if the shortest distance is bigger than the radius
				if(radius <= dotMag)
					return null;
					
				// Using radius, find our new hit ratio
				var hitMag = Math.sqrt(radius*radius - dotMag*dotMag);
				hitRatio = (newVector.getMag() - hitMag) / thisVector.getMag();
			} else if (closestMag+0.001 < radius && closestMag/radius > 0.80 && !movingAway) {
				// Time for the hacky fix... lets say we somehow bump through a line, what do? I'll tell you!	
				// On the real though, if we are heading towards the line, yet inside of the line by < 20%
				// We should use the line's normal to bounce us back. Needs more testing. Seems to work.
				
				normVector.multiply(radius+1 - closestMag);
				this.x += normVector.vx;
				this.y += normVector.vy;
				
				return null;
			}
			
			hitRatio -= 0.000000000001;
			// Re-check the hitRatio after dealing with endpoints (or not)
			if(hitRatio < -0.001 || hitRatio >= 1.0)
				return null;
			
			return new Hit<Line>(line, closestVector.normalize(), hitRatio*modifier);
		}
		
		return null;
	}
	
	/** Test if this circle has collided with another circle */
	public function circleHit( other : Circle, modifier : Float = 1.0 ) : Bool{
		//if(boundingVectorHit(other,modifier))
		//	return false;
		
		var otherVector = new Vector(other.vx,other.vy);
		var thisVector = new Vector(this.vx,this.vy);
					
		// Translate the movement vector of the two circles as if one wasn't moving
		var origVector = thisVector.clone().subtract(otherVector).multiply(modifier).addMagnitude(leftoverMag);
		var regVector = origVector.clone();
		
		// Get the direct vector between the two circles
		var dirVector = Vector.getVector(this.getX(),this.getY(),other.getX(),other.getY());
		
		// No velocity || not moving towards each other, no need to compute
		if(regVector.getMag() == 0 || regVector.dot(dirVector) <= 0)
			return false;
		
		// Get the normalized dot product of the two vectors
		var dotDist = regVector.normalize().dot( dirVector );
		
		// Gets the shortest distance between the two vectors
		var shortestDist = Math.sqrt(dirVector.getMag()*dirVector.getMag() - dotDist*dotDist);
		
		// Calculate the sum of the radii
		var totRadius = this.radius + other.radius;
		
		// If shortest distance is greater than totRadius, no collision will happen
		if(shortestDist > totRadius){
			this.leftoverMag = 0;
			return false;
		}
		
		// Get the distance which must be subtracted from dotDistance (makes the circles close enough to touch)
		var subtractDist = Math.sqrt( totRadius*totRadius - shortestDist*shortestDist );// + 1;
		
		// Multiply the normalized regVector by dotDist - subtractDist
		regVector.multiply(dotDist - subtractDist);
		
		// If the magnitude of the new regVector is less than the old one... we have a hit!!!
		if(regVector.getMag() <= origVector.getMag()){
			var hitPosition = regVector.getMag() / origVector.getMag();
			
			this.x += this.vx*modifier*hitPosition;
			this.y += this.vy*modifier*hitPosition;
			other.x += other.vx*modifier*hitPosition;
			other.y += other.vy*modifier*hitPosition;
			
			//this.beenHit = other.beenHit = true;		
			this.hitVector = Vector.getVector(getX(),getY(),other.getX(),other.getY()).normalize();
			other.hitVector = this.hitVector.clone();	
			
			return true;
		}
		
		return false;
	}
	
	public function realisticBounce( other : Circle, energyLoss:Float = 0 ){
		var otherVector = new Vector(other.vx,other.vy);
		var thisVector = new Vector(this.vx,this.vy);
		
		var a1 = otherVector.dot( hitVector );
		var a2 = thisVector.dot( hitVector );
		
		var hitP = (2.0 * (a1 - a2)) / ( this.getMass() + other.getMass() );
		
		otherVector.subtract( other.hitVector.multiply(hitP*this.getMass()) );
		thisVector.add( this.hitVector.multiply(hitP*other.getMass()));
		
		this.vx = thisVector.vx;
		this.vy = thisVector.vy;
		other.vx = otherVector.vx;
		other.vy = otherVector.vy;
	}
	
	/** Recalculates the velocities so it bounces about the point of impact */
	public function hitBounce(hitVector:Vector, energyLoss:Float = 0){
		hitVector = hitVector.getPerpendicular();
		var velVector = new Vector(vx,vy);
		velVector = hitVector.multiply(2* hitVector.dot(velVector)).subtract(velVector);
		
		if(energyLoss > 0)
			velVector.multiply(1.0 - energyLoss);
			
		vx = velVector.vx;
		vy = velVector.vy;
	}
	
	/** Recalculates the velocities so it slides about the point of impact */
	public function hitSlide(hitVector:Vector, energyLoss:Float = 0, onto:Bool = true){
		var velVector = new Vector(vx,vy);
		var p1Vector = hitVector.getPerpendicular().normalize().multiply( velVector.getMag() );

		velVector = (!onto) ? p1Vector : velVector.onto(p1Vector);
			
		if(energyLoss > 0)
			velVector.multiply(1.0 - energyLoss);
		
		vx = velVector.vx;
		vy = velVector.vy;
	}
	
	public function new(texture:Texture, x:Float, y:Float, radius:Float){
		super(texture);

		this.width = radius*2;
		this.height = radius*2;
		this.radius = radius;
		
		setLoc(x,y);
    }
}
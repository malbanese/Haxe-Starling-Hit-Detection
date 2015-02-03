/**
  * This class is meant to represent vectors and some simple math.
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */
  
package com.cykon.haxe.cmath;

class Vector {
	public var vx : Float;
	public var vy : Float;
	public var mag : Float;
	public var magDirty : Bool = true;
	
	public function new(vx : Float, vy : Float){
		this.vx = vx;
		this.vy = vy;
		magDirty = true;
	}
	
	/** Returns a vector about two points */
	public static function getVector(x1:Float,y1:Float,x2:Float,y2:Float):Vector{
		return new Vector(x2-x1,y2-y1);
	}
	
	/** Creates an identical instance of this object */
	public function clone() : Vector{
		return new Vector(vx,vy);
	}
	
	/** Multiplies this vector by some value */
	public function multiply(mag : Float) : Vector{
		vx *= mag;
		vy *= mag;
		magDirty = true;
		return this;
	}
	
	/** Subtracts a vector from this one */
	public function subtract(vector : Vector):Vector{
		vx -= vector.vx;
		vy -= vector.vy;
		magDirty = true;
		return this;
	}
	
	/** Adds a vector with this one */
	public function add(vector : Vector):Vector{
		vx += vector.vx;
		vy += vector.vy;
		magDirty = true;
		return this;
	}
	
	/** Normalizes this vector */
	public function normalize() : Vector{
		vx = vx / getMag();
		vy = vy / getMag();
		magDirty = true;
		return this;
	}
	
	/** Rotates the vector */
	public function rotate(radian:Float) : Vector{
		if(radian == 0)
			return this;
			
		var cos = Math.cos(radian);
		var sin = Math.sin(radian);
		
		var nvx = vx*cos - vy*sin;
		var nvy = vx*sin + vy*cos;
		
		vx = nvx;
		vy = nvy;
		return this;
	}
	
	/** Adds some.getMag()nitude to this vector */
	public function addMagnitude(magnitude:Float):Vector{
		if(magnitude == 0)
			return this;

		magnitude += this.getMag();
		return normalize().multiply(magnitude);
	}
	
	/** Performs a dot product between this and another vector */
	public function dot( vector : Vector ) : Float{
		return (this.vx*vector.vx + this.vy*vector.vy);
	}
	
	/** Performs a cross product between this and another vector */
	public function cross( vector : Vector ) : Float {
		return (this.vx*vector.vy - this.vy*vector.vx) % (Math.PI*2);	
	}
	
	/** Projects this vector onto another vector */
	public function onto( vector : Vector ) : Vector{
		var multiplier = dot(vector) / (vector.getMag()*vector.getMag());
		var newVector = new Vector(multiplier*vector.vx, multiplier*vector.vy);
		return newVector;
	}
	
	/** Gets the angle between two vectors */
	public function getVectorAngle( vector : Vector ) : Float{
		return Math.atan2(vy,vx) - Math.atan2(vector.vy,vector.vx);
	}
	
	/** Returns the angle of this vector */
	public function getAngle() : Float{
		return Math.atan2(vy,vx);
	}
	 
	/** Obtains a perpendicular vector */
	public function getPerpendicular(){
		return new Vector(-vy,vx);
	}
	
	/** Returns a vector in the opposite direction */
	public function getOpposite() : Vector{
		return new Vector(-vx,-vy);
	}
	
	/** Get the magnitude of this vector */
	public function getMag() : Float{
		if(magDirty){
			mag = Math.sqrt(vx*vx + vy*vy);
			magDirty = false;
		}
		
		return mag;
	}
}
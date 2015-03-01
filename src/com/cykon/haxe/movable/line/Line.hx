package com.cykon.haxe.movable.line;

/**
  * This class is meant to represent a line object.
  * In the future, velocities and rotational momentum
  * will be able to be applied to it.
  *
  * Author: Michael Albanese
  * Creation Date: January 31, 2015
  *
  */
 
 import com.cykon.haxe.movable.Hit;
 import com.cykon.haxe.movable.Point;
 import com.cykon.haxe.cmath.Vector;
 import com.cykon.haxe.util.VectorDisplay;
 import starling.display.Sprite;
 
 class Line{
	
	var P1:Point;
	var P2:Point;
	var norm:Vector;
	var vector:Vector;
	public static var DEBUG:Sprite;
	
	public function getVector():Vector{
		return vector.clone();
	}
	
	public function getNorm():Vector{
		return norm.clone();
	}
	
	public function getP1():Point{
		return P1;
	}
	
	public function getP2():Point{
		return P2;
	}
	
	public static function getLine(x1:Float, y1:Float, x2:Float, y2:Float):Line{
		return new Line(new Point(x1,y1), new Point(x2,y2));
	}
	
	public function lineHit( line : Line, modifier : Float = 1.0 ): Point {		
		var thisVector = new Vector(vector.vx,vector.vy).multiply(modifier);
		
		// Get the direct vector between this and a point on the line
		var pointVector = Vector.getVector(this.P1.x, this.P1.y, line.P1.x, line.P1.y);
		
		// Preliminary check to make sure that the vector is going towards the line
		var normVector = line.getNorm();
		
		if(normVector.dot(pointVector) >  0){
			normVector = normVector.getOpposite();
		}
		
		
		
		// Define the closest vector to work with
		var closestVector = normVector.clone();
		
		
		
		// In this case, the vector is moving away from the line
		var movingAway = false;
		if(closestVector.dot(thisVector) >= 0){
			return null;
		}
		
		// Get the closest vector between the circle and the line
		var closestMag = closestVector.multiply(closestVector.dot(pointVector)).getMag();
		
		// Get the closest vector in regards to the circle's velocity
		closestVector.normalize().multiply( closestVector.dot(thisVector) );
		
		//DEBUG.removeChildren(0,-1,true);
		//DEBUG.addChild( VectorDisplay.display(closestVector, this.P1.x, this.P1.y, 2, 0x0000FF) );
	
		// Get the hit ratio, to correct thisVector with
		var hitRatio = (closestMag) / closestVector.getMag();
		
		
		
		// We have a hit, but still need to check if we hit within the line's bounds
		if(hitRatio <= 1.0){
			// New (x,y) positions
			var nx = this.P1.x + vector.vx*hitRatio*modifier;
			var ny = this.P1.y + vector.vy*hitRatio*modifier;
			
			// Vectors from each end point to the circle
			var pv1 = Vector.getVector( nx, ny, line.getP1().x, line.getP1().y );
			var pv2 = Vector.getVector( nx, ny, line.getP2().x, line.getP2().y );
			
			// Vectors are in the same direction!~
			if(pv1.dot(pv2) < 0){
				return new Point(nx,ny);
			}
		}
		
		return null;
	}
	
	public function new(P1:Point, P2:Point){
		this.P1 = P1;
		this.P2 = P2;
		
		vector = Vector.getVector(P1.x,P1.y,P2.x,P2.y);
		norm = vector.clone().normalize().getPerpendicular();
	}
 }
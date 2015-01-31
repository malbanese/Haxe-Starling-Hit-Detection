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
 
 import com.cykon.haxe.movable.Point;
 import com.cykon.haxe.cmath.Vector;
 
 class Line{
	
	var P1:Point;
	public var P2:Point;
	var norm:Vector;
	
	public function getP1():Point{
		return P1;
	}
	
	public function getP2():Point{
		return P2;
	}
	
	public static function getLine(x1:Float, y1:Float, x2:Float, y2:Float):Line{
		return new Line(new Point(x1,y1), new Point(x2,y2));
	}
	
	public function new(P1:Point, P2:Point){
		this.P1 = P1;
		this.P2 = P2;
		
		var vectorLine:Vector = Vector.getVector(P1.x,P1.y,P2.x,P2.y);
		norm = vectorLine.normalize().getPerpendicular();
	}
 }
package com.cykon.haxe.movable;

/**
  * This class represents a simple (x,y) point.
  *
  * Author: Michael Albanese
  * Creation Date: January 31, 2015
  *
  */
 
 class Point{
	
	public var x:Float;
	public var y:Float;
	
	public function new(x:Float, y:Float){
		this.x = x;
		this.y = y;
	}
	
	public function distance(P1:Point):Float{
		return Math.sqrt( (P1.x-this.x)*(P1.x-this.x) + (P1.y-this.y)*(P1.y-this.y) ) ;
	}
 }
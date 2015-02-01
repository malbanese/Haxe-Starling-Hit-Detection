/**
  * This class is meant to utilize the included drawing library
  * to visualize exactly what a vector looks like.
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */

package com.cykon.haxe.util;

import starling.display.Shape;
import com.cykon.haxe.cmath.Vector;

class VectorDisplay{
	public static function display( vector:Vector, origX:Float, origY:Float, thickness:Int = 2, color = null ):Shape{
		var shape:Shape = new Shape();
		
		shape.x = origX;
		shape.y = origY;
		
		if(color == null)
			color = Math.round(Math.random()*0xFFFFFF);
		
		shape.graphics.lineStyle(thickness, color, 1.0);
		shape.graphics.lineTo(vector.vx, vector.vy);
		
		shape.graphics.beginFill(color, 1.0);
		var v1Normal = vector.clone().normalize().multiply(5).rotate(Math.PI * 3/4);
		shape.graphics.lineTo(vector.vx + v1Normal.vx, vector.vy + v1Normal.vy);
		shape.graphics.moveTo(vector.vx, vector.vy);
		
		var v2Normal = vector.clone().normalize().multiply(5).rotate(-Math.PI * 3/4);
		shape.graphics.lineTo(vector.vx + v2Normal.vx, vector.vy + v2Normal.vy);
		shape.graphics.lineTo(vector.vx + v1Normal.vx, vector.vy + v1Normal.vy);
		shape.graphics.endFill();
		
		return shape;
	}
}
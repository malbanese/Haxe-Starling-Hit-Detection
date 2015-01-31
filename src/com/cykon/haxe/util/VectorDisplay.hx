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
	public static function display( vector:Vector, origX:Float, origY:Float ):Shape{
		var shape:Shape = new Shape();
		
		shape.x = origX;
		shape.y = origY;
		
		shape.graphics.lineStyle(2, Math.round(Math.random()*0xFFFFFF), 1.0);
		shape.graphics.lineTo(vector.vx, vector.vy);
		
		return shape;
	}
}
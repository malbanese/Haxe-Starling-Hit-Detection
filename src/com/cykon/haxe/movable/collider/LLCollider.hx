package com.cykon.haxe.movable.collider;

/**
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  * This collider is meant to find the closest hitTest
  * from a circle to a group of lines
  */

import com.cykon.haxe.movable.Hit;
import com.cykon.haxe.movable.line.Line;
import com.cykon.haxe.movable.circle.Circle;
import com.cykon.haxe.movable.Point;

class LLCollider extends List<Line> {
	
	public function hitTest(line:Line, hitCallback:Line->Point->Void, returnFirst:Bool = false):Point{
		var closestPoint:Point = null;
		var closestDistance:Float = 9999;
		
		for(testLine in this){
			var hit:Point = line.lineHit(testLine);
			var hitDistance:Float = 99999;
			
			if(hit!=null)
				hitDistance = hit.distance(line.getP1());
				
			if(hit != null && closestPoint == null || hit != null && hitDistance < closestDistance ){
				closestPoint = hit;
				closestDistance = hitDistance;
				
				if(returnFirst)
					break;
			}
		}
		
		if(closestPoint != null && hitCallback != null)
			hitCallback(line, closestPoint);
		
		return closestPoint;
	}
	
	public function addLines(a_Line:Array<Line>){
		for(line in a_Line)
			this.add(line);
	}
	
	public function new() {
		super();
    }
}
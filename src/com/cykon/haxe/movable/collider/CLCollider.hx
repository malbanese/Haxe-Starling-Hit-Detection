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

class CLCollider extends List<Line> {
	
	public function iterativeHitTest(circle:Circle, hitCallback:Circle->Hit<Line>->Void, missCallback:Circle->Float->Void, modifier:Float, maxIter:Int = 5){
		//haxe.Log.clear();
		var hit:Hit<Line> = null;
		
		var workingMod = modifier;
		
		while(maxIter-- != 0 && workingMod > 0){
			hit = hitTest(circle, null, modifier);
			
			if(hit == null){
				missCallback(circle, workingMod);
				return;
			}
			
			workingMod -= hit.getVMod();		
			hitCallback(circle, hit);
		}
	}
	
	public function hitTest(circle:Circle, hitCallback:Circle->Hit<Line>->Void, modifier:Float, returnFirst:Bool = false):Hit<Line>{
		var closestHit:Hit<Line> = null;
		
		for(line in this){
			var hit:Hit<Line> = circle.lineHit(line, modifier);
			
			if(hit != null && closestHit == null || hit != null && hit.getVMod() <= closestHit.getVMod()){
				closestHit = hit;
				if(returnFirst)
					break;
			}
		}
		
		if(closestHit != null && hitCallback != null)
			hitCallback(circle, closestHit);
		
		return closestHit;
	}
	
	public function addLines(a_Line:Array<Line>){
		for(line in a_Line)
			this.add(line);
	}
	
	public function new() {
		super();
    }
}
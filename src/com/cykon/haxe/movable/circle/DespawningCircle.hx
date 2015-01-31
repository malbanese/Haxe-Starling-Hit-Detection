/**
  * This class is meant to represent a circle instance
  * which will despawn after exiting the screen area.
  * The circle may start outside of the screen.
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */

package com.cykon.haxe.movable.circle;
import starling.textures.Texture;

class DespawningCircle extends Circle {
	var stageWidth:Float;
	var stageHeight:Float;
	var prevDist:Float = Math.POSITIVE_INFINITY;
	var despawnMe:Bool = false;
	
	public function new(texture:Texture, x:Float, y:Float, radius:Float, stageWidth:Float, stageHeight:Float){
		super(texture,x,y,radius);
		this.stageWidth = stageWidth;
		this.stageHeight = stageHeight;
	}
	
	/** Overriden version of the Circle's apply velocity,
	  * If the circle isnt heading towards the center && it's off screen, we despawn it */
	public override function applyVelocity(modifier:Float):Bool{
		if(despawnMe)
			return true;
			
		super.applyVelocity(modifier);
		
		var distance = getDistance();
		if(distance > prevDist && isOutOfBounds()){
			despawnMe = true;
			this.removeFromParent();
		}
			
		prevDist = distance;
		return true;
	}
	
	/** Returns whether or not the circle has been despawned */
	public function hasDespawned():Bool{
		return despawnMe;
	}
	
	/** Checks to see if the circle is out of bounds or not */
	private function isOutOfBounds():Bool{
		var x = getX();
		var y = getY();
		return( x <= -radius || x >= stageWidth+radius || y <= -radius || y >= stageHeight+radius );
	}
	
	/** Gets the distance of the circle to the center of the stage */
	private function getDistance():Float{
		return Math.sqrt(Math.pow( getX()-stageWidth/2, 2) + Math.pow(getY()-stageHeight/2, 2) );
	}
}
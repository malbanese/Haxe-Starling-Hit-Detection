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
import com.cykon.haxe.cmath.Vector;

class TrackingCircle extends DespawningCircle {

	private var trackCircle : Circle;
	private var maxAngle : Float = Math.PI*2;
	
	public function new(texture:Texture, x:Float, y:Float, radius:Float, stageWidth:Float, stageHeight:Float, trackCircle : Circle){
		super(texture, x, y, radius, stageWidth, stageHeight);
		this.trackCircle = trackCircle;
	}
	
	public function setMaxAngle(maxAngle:Float){
		this.maxAngle = maxAngle;
	}
	
	/** Overriden version of the Circle's apply velocity,
	  * Follow the player! Hurrah!*/
	public override function applyVelocity(modifier:Float):Bool{	
		var returnVal = super.applyVelocity(modifier);
		
		var thisVector = new Vector(vx,vy);
		var directVector = Vector.getVector(getX(),getY(),trackCircle.getX(),trackCircle.getY());
		var angle = directVector.getVectorAngle( thisVector );
		
		// Angle correction
		if(Math.abs(angle) > Math.PI){
			angle -= angle/Math.abs(angle)*2*Math.PI;
		}
			
		// Apply a maximum angle if the angle is greater than that
		if(Math.abs(angle) > maxAngle){
			angle = angle/Math.abs(angle) * maxAngle;
		}
		
		thisVector = thisVector.rotate(angle).normalize().multiply(thisVector.getMag()+0.01);
		
		vx = thisVector.vx;
		vy = thisVector.vy;
		
		return returnVal;
	}
}
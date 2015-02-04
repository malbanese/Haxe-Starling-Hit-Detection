package com.cykon.haxe.movable;

/**
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */

import com.cykon.haxe.cmath.Vector;

class Hit<T> {	
	var hitVector:Vector;
	var vMod:Float;
	var hitObject:T;
	
	public function getHitVector():Vector{
		return hitVector.clone();
	}
	
	public function getVMod():Float{
		return vMod;
	}
	
	public function getHitObject():T{
		return hitObject;
	}
	
	public function new(hitObject:T, hitVector:Vector, vMod:Float) {
		this.hitObject = hitObject;
		this.vMod = vMod;
		this.hitVector = hitVector;
	}
}
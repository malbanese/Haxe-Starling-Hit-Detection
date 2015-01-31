/**
  * This class is meant to solve polynomials
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */
  
package com.cykon.haxe.cmath;
import com.cykon.haxe.cmath.Vector;

class Polynomial {

	public static function hitSim(c1:Vector,v1:Vector,r1:Float,c2:Vector,v2:Vector,r2:Float){
		var r = r1 + r2;
		var x = v2.vx - v1.vx;
		var y = v2.vy - v1.vy;
		var xs = c2.vx - c1.vx;
		var ys = c2.vy - c1.vy;
		var a = x*x + y*y;
		var b = 2*(x*xs+y*ys);
		var c = xs*xs + ys+ys;
		
		return [polyNewton(0.0, a, b, c), polyNewton(1.0, a, b, c)];
	}
	
	public static function polyNewton(guess : Float, a : Float, b: Float, c : Float) : Float {
		var x0 = guess; // Initial value to test with;
		var tolerance = 0.0001; // Tolerance until we say an answer is correct
		var maxIter = 20; // The maximum number of iterations that will be applied
		var epsilon = 0.00000000000001; // Minimum dividable number
		for( i in 0...maxIter ){
			var y = a*x0*x0 + b*x0 + c;
			var yprime = 2*a*x0 + b;
			
			// Can't divide by a small enough number, no solution 
			if( Math.abs(yprime) < epsilon ){
				return Math.NaN;
			}
			
			var x1 = x0 - y/yprime;
			
			// We have found a solution
			if( x1 == 0 || Math.abs((x1-x0)/x1) < tolerance ){
				return x1;
			}

			x0 = x1;
		}
		
		return Math.NaN;
	}
}
package com.cykon.haxe.movable.line;

/**
  * This class is meant to provide a way to
  * draw line objects to the screen.
  *
  * Author: Michael Albanese
  * Creation Date: January 31, 2015
  *
  */
 
 import starling.core.RenderSupport;
 import com.cykon.haxe.movable.Point;
 import com.cykon.haxe.cmath.Vector;
 
 class LineDisplay extends starling.display.Shape{
	var lines:List<Line> = new List<Line>();
	var _thickness:Float;
	var _color:UInt;
	var _alpha:Float;
	
	public function addLines(a_Line:Array<Line>){
		for(line in a_Line)
			lines.add(line);
	}
	
	public function add(line:Line){
		lines.add(line);
	}
	
	public function remove(line:Line){
		lines.remove(line);
	}
	
	public function lineStyle(thickness:Float, color:UInt, alpha:Float){
		_thickness = thickness;
		_color = color;
		_alpha = alpha;
	}
	
	public override function render(support:RenderSupport, parentAlpha:Float):Void{
		this.graphics.clear();
		this.graphics.lineStyle(_thickness, _color, _alpha);
		for(line in lines){
			this.graphics.moveTo(line.getP1().x, line.getP1().y);
			this.graphics.lineTo(line.getP2().x, line.getP2().y);
		}
		
		super.render(support, parentAlpha);
	}
	
	public function new(thickness:Float, color:UInt, alpha:Float, lines:List<Line> = null){
		super();
		
		lineStyle(thickness, color, alpha);
		if(lines != null){
			this.lines = lines;
		}
	}
 }
/**
  * This class is meant to be the main driver behind a simple game.
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */
package com.cykon.haxe.example;

import starling.utils.AssetManager;
import starling.textures.Texture;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.display.Stage;
import starling.display.Shape;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.RenderTexture;
import starling.filters.BlurFilter;
import flash.system.System;

import com.cykon.haxe.movable.circle.PlayerCircle;
import com.cykon.haxe.movable.circle.Circle;
import com.cykon.haxe.movable.line.Line;
import com.cykon.haxe.movable.line.LineDisplay;
import com.cykon.haxe.util.VectorDisplay;
import com.cykon.haxe.movable.collider.CLCollider;
import com.cykon.haxe.movable.collider.LLCollider;
import com.cykon.haxe.movable.Hit;
import com.cykon.haxe.movable.Point;

class Shadows extends starling.display.Sprite {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at frameRate */
	static var perfectDeltaTime : Float = 1/60;
	
	// Reference to the global stage
	static var globalStage : Stage = null;
	
	// Keep track of game assets
	var assets : AssetManager  = new AssetManager();
	var running = true;
	
	var mouseX:Float;
	var mouseY:Float;
	var spawnX:Float;
	var spawnY:Float;
	
	var player:PlayerCircle;
	var basicCollider:CLCollider;
	var lineCollider:LLCollider;
	
	var hitType = true;
	var hitPause = true;
	var displayVectors = false;
	
	var L1:Line = null;
	var hlDisplay:LineDisplay;
	
	var numDegrees:Int = 200;
	var radianArray:Array<Point> = new Array<Point>();
	var lightRadius:Int = 300;
	// Simple constructor
    public function new() {
        super();
		populateAssetManager();
    }
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets.enqueue("../assets/circle.png");
		assets.enqueue("../assets/circle2.png");
		assets.loadQueue(function(percent){
			// When percent is 1.0 all assets are loaded
			if(percent == 1.0){
				startScreen();
			}
		});
	}
	
	/** Do stuff with the menu screen */
	private function startScreen(){
		startGame();
	}
	
	
	var bFilter:BlurFilter = new BlurFilter(0.5,0.5,0.5);
	var shadowDisplay:Image;
	var shadowTexture:RenderTexture;
	var lineCanvas:Shape;
	/** Function to be called when we are ready to start the game */
	private function startGame() {		
	
		
		// Populate the radian array
		var spacer:Float = 360/numDegrees;
		for(i in 0...numDegrees){
			var radian = Math.PI*i*spacer/180;
			radianArray.push( new Point( Math.cos(radian), Math.sin(radian) ) );
		}
		
		lineCanvas = new Shape();
		lineCanvas.blendMode = "erase";
		
		shadowTexture = new RenderTexture(stage.stageWidth, stage.stageHeight);
		shadowTexture.clear(0,1);
		
		shadowDisplay = new Image(shadowTexture);
		shadowDisplay.filter = bFilter;
		
		addChild(shadowDisplay);
		
		player = new PlayerCircle( assets.getTexture("circle"), 200, 100, 15, 10);
		
		var hlen = 300;
		var vlen = 200;
		var a_Line:Array<Line> = [
			Line.getLine(0,0,0,globalStage.stageHeight),
			Line.getLine(0,globalStage.stageHeight,globalStage.stageWidth, globalStage.stageHeight),
			Line.getLine(globalStage.stageWidth, globalStage.stageHeight, globalStage.stageWidth, 0),
			Line.getLine(globalStage.stageWidth, 0, 0, 0),
			Line.getLine(640-hlen,360,640,360-vlen),
			Line.getLine(640,360-vlen,640+hlen,360),
			Line.getLine(640+hlen,360,640,360+vlen-250),
			Line.getLine(640,360+vlen-250,640-hlen,360),
			Line.getLine(200,5,globalStage.stageWidth,100),
			Line.getLine(0,globalStage.stageHeight-100, globalStage.stageWidth-200,globalStage.stageHeight-5),
			Line.getLine(0,100,200,5),
			Line.getLine(globalStage.stageWidth - 200, globalStage.stageHeight-5, globalStage.stageWidth, globalStage.stageHeight-100)];
		
		basicCollider = new CLCollider();
		lineCollider = new LLCollider();
		var lineDisplay = new LineDisplay(2,0,1);
		hlDisplay = new LineDisplay(2,0xFF0000,1);
		
		lineCollider.addLines(a_Line);
		basicCollider.addLines(a_Line);
		lineDisplay.addLines(a_Line);
		
		addChild(player);
		addChild(hlDisplay);
		
		/*trace("<CLICK> to set player position.");
		trace("<UP / DOWN> to control light radius.");
		trace("<WASD> to control player position.");
		trace("<G> to pause");*/
		
		// Start the onEnterFrame calls
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);	
		globalStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		globalStage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		globalStage.addEventListener(TouchEvent.TOUCH, onTouch);
	}
	
	/** The game is over! */
	private function triggerGameOver(){		
	}
	
	/** Restart the game */
	private function restartGame(){
	}
	
	
	
	var prevX:Float = 0;
	var prevY:Float = 0;
	var skip = 1;
	/** Function called every frame update, main game logic loop */
	private function onEnterFrame( event:EnterFrameEvent ) {
		if(!running)
			return;
	
		// Create a modifier based on time passed / expected time
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		
		basicCollider.iterativeHitTest(player, circleLineHit, circleLineMiss, modifier);
		
		if(prevX == player.x && prevY == player.y|| skip++ % 2 != 0)
			return;
		skip = 1;
		
		prevX = player.x;
		prevY = player.y;
		lineCanvas.graphics.clear();
		
		lineCanvas.graphics.beginFill(0,1);
		
		var firstPoint:Point = null;	
		for(i in 0...numDegrees){
			var line:Line = Line.getLine(player.getX(), player.getY(), player.getX() + radianArray[i].x*lightRadius, player.getY() + radianArray[i].y*lightRadius);
			var point:Point = lineCollider.hitTest(line, null);
			
			if(point == null)
				point = line.getP2();
				
			if(firstPoint == null){
				firstPoint = point;
				lineCanvas.graphics.moveTo(point.x, point.y);
			}
			
			lineCanvas.graphics.lineTo(point.x, point.y);
		}
		
		if(firstPoint != null)
			lineCanvas.graphics.lineTo(firstPoint.x, firstPoint.y);
		
		lineCanvas.graphics.endFill();
		
		shadowTexture.clear(0,1);
		shadowTexture.draw(lineCanvas);
	}
	
	private function circleLineMiss(circle:Circle, modifier:Float){
		circle.applyVelocity(modifier);
	}
	
	private function circleLineHit(circle:Circle, hit:Hit<Line>){		
		circle.applyVelocity(hit.getVMod());
		circle.hitSlide(hit.getHitVector());
		
		if(!hitPause)
			running = false;
	}
	
	/** Used to detect clicks */
	private function onTouch( event:TouchEvent ){
		var touch:Touch = event.touches[0];
		if(touch.phase == "ended"){
			player.setLoc(touch.globalX, touch.globalY);
		}
		
		mouseX = touch.globalX;
		mouseY = touch.globalY;
	}
	
	/** Used to keep track of when a key is unpressed */
	private function keyUp(event:KeyboardEvent):Void{
		player.keyUp(event.keyCode);
	}
	
	/** Used to keep track when a key is pressed */
	private function keyDown(event:KeyboardEvent){
		player.keyDown(event.keyCode);
		
		if(event.keyCode == 38){
			lightRadius += 25;
		}
		if(event.keyCode == 40){
			lightRadius -= 25;
		}
		if(event.keyCode == 70){
			hitType = !hitType;
			trace(hitType ? "Bouncing." : "Sliding.");
		}
		
		if(event.keyCode == 71){
			running = !running;
			trace(running ? "Running." : "Paused.");
		}
		
		if(event.keyCode == 72){
			displayVectors = !displayVectors;
		}
	}
	
	/** Main method, used to set up the initial game instance */
    public static function main() {		
        try {
			// Attempt to start the game logic 
			var starling = new starling.core.Starling(Shadows, flash.Lib.current.stage, null, null, "auto", "baseline");
			starling.showStats = true;
            globalStage = starling.stage; 
			starling.start();  
        } catch(e:Dynamic){
            trace(e);
        }
    }
}
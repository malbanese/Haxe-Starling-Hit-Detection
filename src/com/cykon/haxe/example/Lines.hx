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
import starling.display.Stage;
import starling.display.Shape;
import flash.system.System;

import com.cykon.haxe.movable.circle.Circle;
import com.cykon.haxe.movable.line.Line;
import com.cykon.haxe.movable.line.LineDisplay;
import com.cykon.haxe.cmath.Vector;
import com.cykon.haxe.util.VectorDisplay;

class Lines extends starling.display.Sprite {
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at frameRate */
	static var perfectDeltaTime : Float = 1/60;
	
	// Reference to the global stage
	static var globalStage : Stage = null;
	
	// Keep track of game assets
	var assets : AssetManager  = new AssetManager();
	var running = true;
	
	// Simple constructor
    public function new() {
        super();
		populateAssetManager();
    }
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets.enqueue("../assets/circle.png");
		assets.loadQueue(function(percent){
			// Ideally we would have some feedback here (loading screen)
			
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
	
	var L1:Line;
	/** Function to be called when we are ready to start the game */
	private function startGame() {
		var circle = new Circle( assets.getTexture("circle"), 100, 100, 25 );
			circle.setVelocity(-200,101);
		addChild(circle);
		
		
		var line = Line.getLine(400,300,200,400);
		var lineDisplay = new LineDisplay(2,0,1);
		lineDisplay.addLines([line]);
		
		// Display the circle's velocity vector
		addChild( VectorDisplay.display(circle.getVelVector(), circle.getX(), circle.getY()) );
		
		// Display the line's norm multiplied by 25
		addChild(VectorDisplay.display( line.getNorm().multiply(25), line.getP1().x, line.getP1().y ));
		
		// Display the line
		addChild(lineDisplay);
		
		trace("Hit: " + circle.lineHit(line));
		
		// Start the onEnterFrame calls
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);	
		globalStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		globalStage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
	}
	
	/** The game is over! */
	private function triggerGameOver(){		
	}
	
	/** Restart the game */
	private function restartGame(){
	}
	
	/** Function called every frame update, main game logic loop */
	private function onEnterFrame( event:EnterFrameEvent ) {
		if(!running)
			return;
			
		// Create a modifier based on time passed / expected time
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
	}
	
	/** Used to keep track of when a key is unpressed */
	private function keyUp(event:KeyboardEvent):Void{
	}
	
	/** Used to keep track when a key is pressed */
	private function keyDown(event:KeyboardEvent){
	}
	
	/** Main method, used to set up the initial game instance */
    public static function main() {
		// Frame rate the game ~should~ run at
		
        try {
			// Attempt to start the game logic 
			var starling = new starling.core.Starling(Lines, flash.Lib.current.stage);
			starling.showStats = true;
            globalStage = starling.stage; 
			starling.start();  
        } catch(e:Dynamic){
            trace(e);
        }
    }
}
/**
  * This class is meant to be the main driver behind a simple game.
  *
  * Author: Michael Albanese
  * Creation Date: January 25, 2015
  *
  */
package com.cykon.haxe.example;

import com.cykon.haxe.generator.*;
import com.cykon.haxe.movable.circle.*;
import starling.utils.AssetManager;
import starling.textures.Texture;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.display.Stage;
import starling.display.Quad;
import starling.text.TextField;
import flash.system.System;
import com.cykon.haxe.cmath.Polynomial;
import com.cykon.haxe.cmath.Vector;

class Circles extends starling.display.Sprite {
	
	// The desired frame rate which the game should run at
	static var frameRate : Int = 30;
	
	/* The 'perfect' update time, used to modify velocities in case
	   the game is not quite running at $frameRate */
	static var perfectDeltaTime : Float = 1/60; //1 / frameRate;
	
	// Reference to the global stage
	static var globalStage : Stage = null;
	
	// Keep track of game assets
	var assets : AssetManager  = new AssetManager();
	
	// Reference to the player circle, which the user will control
	var a_Player : List<PlayerCircle>;
	
	// Generator which will spawn enemys periodically
	var enemyGenerator : DCircleGenerator;
	
	// Generator which will spawn points!
	var pointGenerator : SCircleGenerator;
	var points = 0;
	var revivePoints = -1;
	var running = true;
	var frequency = 50;
	var scoreText:TextField = null;
	var sTime:Float;
	
	// Simple constructor
    public function new() {
        super();
		populateAssetManager();
    }
	
	/** Function used to load in any assets to be used during the game */
	private function populateAssetManager() {
		assets.enqueue("../assets/circle.png");
		assets.enqueue("../assets/circle2.png");
		assets.enqueue("../assets/circle_point.png");
		assets.enqueue("../assets/circle_green_glow.png");
		assets.enqueue("../assets/circle_green_boss.png");
		assets.loadQueue(function(percent){
			// Ideally we would have some feedback here (loading screen)
			
			// When percent is 1.0 all assets are loaded
			if(percent == 1.0){
				startScreen();
			}
		});
	}
	
	/** Function to be called when we are ready to start the game */
	private function startGame() {
		a_Player = new List<PlayerCircle>();
		
		// Instantiate a new player at the center of the screen with radius 15 and speed 15
		var player = new PlayerCircle(assets.getTexture("circle"), globalStage.stageWidth/2.0, globalStage.stageHeight/2.0, 25, 8);
		
		// Add our player to the scene graph
		this.addChild(player);
		a_Player.add(player);
		
		// Initiate our enemy generator
		enemyGenerator = new DCircleGenerator(this, assets.getTexture("circle_green_glow"), 1, 5, 10, 70, 500, globalStage.stageWidth, globalStage.stageHeight);		
		pointGenerator = new SCircleGenerator(this, assets.getTexture("circle_point"), 20, globalStage.stageWidth, globalStage.stageHeight);
		pointGenerator.generate();
		
		// Reset some variables
		points = 0;
		running = true;
		revivePoints = -1;
		haxe.Log.clear();
		sTime = flash.Lib.getTimer()/1000;
		
		// Start the onEnterFrame calls
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);	
		globalStage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		globalStage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
	
		scoreText = new TextField(100,25, "0");
		scoreText.fontSize = 12;
		scoreText.color = 0xFFFFFF;
		scoreText.hAlign = "left";
		scoreText.x = 5;
		addChild(scoreText);
	}
	
	
	/** Function called every frame update, main game logic loop */
	private function onEnterFrame( event:EnterFrameEvent ) {
		if(!running)
			return;
			
		// Create a modifier based on time passed / expected time
		var modifier = (event == null) ? 1.0 : event.passedTime / perfectDeltaTime;
		
		for(player in a_Player){
			if(player.isAlive){
				// Check to see if this player has hit a point in the point generator
				if(pointGenerator.circleHit( player, modifier )){
					increasePointCounter(player);
					pointGenerator.generate(); 		// Spawn a new point object
					
					// Work with the revivePoint counter to possibly revive dead player
					if(revivePoints > -1){
						revivePoints += 1;
						
						if(revivePoints == 9)
							scoreText.color = 0xAAFFFF;
						else if(revivePoints == 10){
							scoreText.color = 0xFFFFFF;
							revivePoints = -1;
							haxe.Log.clear();
							
							// Find an alive player
							var alivePlayer : PlayerCircle = null;
							for(player in a_Player){
								if(player.isAlive){
									alivePlayer = player;
								}
							}
							
							// Respawn the other players  on top of the alive player
							for(player in a_Player){
								if(player != alivePlayer){
									player.isAlive = true;
									player.x = alivePlayer.x;
									player.y = alivePlayer.y;
									this.addChild(player);
								}
							}
						}
					}
				}
				
				// Check if the player was hit by anything contained in the enemy generator
				if(enemyGenerator.circleHit( player, modifier )){
					revivePoints = 0;
					player.isAlive = false;
					player.removeFromParent();
					
					if(numAlivePlayers() == 0){
						triggerGameOver();
					}
				}
				
				// Process collisions between players
				for(p2 in a_Player){
					if(p2.isAlive && player != p2){
						if(player.circleHit(p2,modifier))
						player.realisticBounce(p2);
					}
				}
			}
		}
		
		// Update the enemy positions
		enemyGenerator.trigger(modifier, flash.Lib.getTimer());
		
		// Update the player positions
		for(player in a_Player)
			player.applyVelocity(modifier);
	}
	
	/** Return the number of players currently alive */
	private function numAlivePlayers() : Int {
		var alivePlayers = 0;
		for(player in a_Player)
			alivePlayers += (player.isAlive) ? 1 : 0;
		return alivePlayers;	
	}
	
	/** Used to keep track when a key is pressed down */
	private function keyDown(event:KeyboardEvent){
		for(player in a_Player)
			player.keyDown(event.keyCode);
			
		// Restart the game (space)
		if(event.keyCode == 32){
			restartGame();
		}
		
		// Enable a much harder mode (h)
		if(event.keyCode == 72){
			trace("HARD MODE ENGAGED.");
			frequency = 10;
		}
		
		// Bring in a second player (up arrow)
		if(event.keyCode == 38 && a_Player.length < 2 && numAlivePlayers() != 0){
			var player = new PlayerCircle(assets.getTexture("circle2"), globalStage.stageWidth/2.0, globalStage.stageHeight/2.0, 25, 8);
			player.K_LEFT 	= 37;
			player.K_UP 	= 38;
			player.K_RIGHT 	= 39;
			player.K_DOWN 	= 40;
			
			this.addChild(player);
			a_Player.add(player);
		}
	}
	
	/** Increase player points */
	private function increasePointCounter(player:PlayerCircle){
		// Increment point counter
		points += 10;
					
		// Spawn a boss circle on each player if frequency is met
		if(points % frequency == 0){
			for(player in a_Player)
				enemyGenerator.generateBoss(assets.getTexture("circle_green_boss"), player);
		}
		
		scoreText.text = "" + points;
	}
	
	/** Do stuff with the menu screen */
	private function startScreen(){
		startGame();
		pointGenerator.hideChildren();
		for(player in a_Player){
			player.isAlive = false;
			this.removeChild(player);
		}

		var overlay = new Quad(globalStage.stageWidth, globalStage.stageHeight, 0, true);			
		overlay.alpha = 0.7;
		addChild(overlay);
		
		var menuText = new TextField(globalStage.stageWidth, globalStage.stageHeight, "Circles Hit Demo\n\nUse WASD to move!\n\nPress <SPACE> to play.");
		menuText.fontSize = 18;
		menuText.color = 0xFFFFFF;
		addChild(menuText);
		
		for(i in 1...15)
			enemyGenerator.generate();
	}
	
	/** The game is over! */
	private function triggerGameOver(){		
		var overlay = new Quad(globalStage.stageWidth, globalStage.stageHeight, 0, true);			
		overlay.alpha = 0.7;
		addChild(overlay);
		
		var endTime = Math.round((flash.Lib.getTimer()/1000 - sTime)*1000)/1000;
		var menuText = new TextField(globalStage.stageWidth, globalStage.stageHeight, "You lose!\n\nFinal Score: " + points + "\nTime: " + endTime + " seconds\n\nPress <SPACE> to restart");
		menuText.fontSize = 18;
		menuText.color = 0xFFFFFF;
		addChild(menuText);
	}
	
	/** Restart the game */
	private function restartGame(){
		this.removeChildren();
			this.removeEventListeners();
			startGame();
	}
	
	/** Used to keep track of when a key is unpressed */
	private function keyUp(event:KeyboardEvent):Void{
		for(player in a_Player)
			player.keyUp(event.keyCode);
	}
	
	/** Main method, used to set up the initial game instance */
    public static function main() {
		// Frame rate the game ~should~ run at
		
        try {
			// Attempt to start the game logic 
			var starling = new starling.core.Starling(Circles, flash.Lib.current.stage);
			//starling.showStats = true;
            globalStage = starling.stage; 
			starling.start();  
        } catch(e:Dynamic){
            trace(e);
        }
    }
}
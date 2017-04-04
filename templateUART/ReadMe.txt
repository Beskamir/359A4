So we ran out of time to implement everything but a lot of our features are either half baked or fully implemented but unfortunately the features needed to get to those features aren't.

An example would be the map which has the castle, several pipes, 2 types of enemies, gaps, blocks, coins, etc. 

Thus if you'd want to just see a panning view of the map add the following section to the bottom of the _inGame loop in GameplayLogic
		ldr r0, =d_cameraPosition
		ldr r4, [r0]
		add r4, #1
		str r4, [r0]
	and in the same loop comment out 
		bl	f_updateCameraPosition	//Update the camera position

This way the map will scroll with each loop cycle rather than having to wait for the player to walk through the map.

Also there should be a feature to jump to the end of the level but that's not fully implemented.

~Sebastian
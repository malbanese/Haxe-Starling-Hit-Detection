all:
	mkdir -p bin
	haxe -cp ../../src \
	-swf-header 1280:720:60:FFFFFF \
	-swf-version 11.3 \
	-swf bin/Lines.swf \
	-swf-lib ../../Starling.swc \
	-swf-lib ../../Starling-Extension-Graphics.swc \
	--macro "patchTypes('../../starling.patch')" \
	-main com.cykon.haxe.example.Shadows

run:
	make
	cygstart bin/Lines.swf

runkill:
	taskkill /f /IM FlashPlayer16Debug.exe /fi "memusage gt 2"
	make run

clean:
	rm bin/Lines.swf
	mkdir -p bin
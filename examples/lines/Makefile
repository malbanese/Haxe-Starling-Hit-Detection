all:
	mkdir -p bin
	haxe -cp ../../src \
	-swf-header 1280:720:120:FFFFFF \
	-swf-version 11.3 \
	-swf bin/Lines.swf \
	-swf-lib ../../Starling.swc \
	-swf-lib ../../Starling-Extension-Graphics.swc \
	--macro "patchTypes('../../starling.patch')" \
	-main com.cykon.haxe.example.Lines

run:
	make
	cygstart bin/Lines.swf

clean:
	rm bin/Lines.swf
	mkdir -p bin
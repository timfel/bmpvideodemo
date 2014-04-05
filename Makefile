default: libsdlpixels.so

sdlpixels.o: sdlpixels.c
	gcc -fPIC `sdl-config --cflags --libs` \
	    -o sdlpixels.o -c sdlpixels.c

libsdlpixels.so: sdlpixels.o
	gcc -shared `sdl-config --cflags` \
	    -Wl,-export-dynamic,-soname,libsdlpixels.so,-no-undefined \
	    -o libsdlpixels.so sdlpixels.o -lc `sdl-config --libs`

clean:
	rm -f libsdlpixels.so sdlpixels.o

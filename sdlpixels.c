#include "SDL.h"

void* SDL_get_pixels(SDL_Surface* screen) {
    return screen->pixels;
}

int SDL_get_event() {
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
	// loop to get to the latest event
    }

    switch(event.type) {
    case SDL_QUIT:
	return 0;
    case SDL_KEYUP:
	if (event.key.keysym.sym == SDLK_RIGHT) {
	    return 1;
	} else if (event.key.keysym.sym == SDLK_LEFT) {
	    return -1;
	} else if (event.key.keysym.sym == SDLK_q || event.key.keysym.sym == SDLK_ESCAPE) {
	    return 0;
	}
    }
    return 2;
}

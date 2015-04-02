/*
 * $Id: screen3d.d,v 1.2 2004/05/14 14:35:39 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.sdl.screen3d;

private import std.conv;
private import std.string;
private import gl3n.linalg;
private import derelict.sdl2.sdl;
private import derelict.opengl3.gl;
private import abagames.util.logger;
private import abagames.util.sdl.screen;
private import abagames.util.sdl.sdlexception;

/**
 * SDL screen handler(3D, OpenGL).
 */
public class Screen3D: Screen {
 public:
  static float brightness = 1;
  static int width = 640;
  static int height = 480;
  static bool windowMode = false;
  static float nearPlane = 0.1;
  static float farPlane = 1000;

 private:
  SDL_Window* _window;

  protected abstract void init();
  protected abstract void close();

  public void initSDL() {
    // Initialize Derelict.
    DerelictSDL2.load();
    DerelictGL.load();
    // Initialize SDL.
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
      throw new SDLInitFailedException(
        "Unable to initialize SDL: " ~ to!string(SDL_GetError()));
    }
    // Create an OpenGL screen.
    Uint32 videoFlags;
    if (windowMode) {
      videoFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE;
    } else {
      videoFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_FULLSCREEN_DESKTOP;
    }
    _window = SDL_CreateWindow("",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        width, height, videoFlags);
    if (_window == null) {
      throw new SDLInitFailedException
        ("Unable to create SDL screen: " ~ to!string(SDL_GetError()));
    }
    SDL_Renderer* _renderer = SDL_CreateRenderer(_window, -1, 0);
    SDL_RenderSetLogicalSize(_renderer, width, height);
    // Reload GL now to get any features.
    DerelictGL.reload();
    glViewport(0, 0, width, height);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    resized(width, height);
    SDL_ShowCursor(SDL_DISABLE);
    init();
  }

  // Reset viewport when the screen is resized.

  public void screenResized() {
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    const float ratio = cast(float) height / cast(float) width;
    mat4 persp = mat4.perspective(
      -nearPlane, nearPlane,
      -nearPlane * ratio, nearPlane * ratio,
      0.1f, farPlane);
    glMultMatrixf(persp.transposed.value_ptr);
    glMatrixMode(GL_MODELVIEW);
  }

  public void resized(int width, int height) {
    this.width = width; this.height = height;
    screenResized();
  }

  public void closeSDL() {
    close();
    SDL_ShowCursor(SDL_ENABLE);
  }

  public void flip() {
    handleError();
    SDL_GL_SwapWindow(_window);
  }

  public void clear() {
    glClear(GL_COLOR_BUFFER_BIT);
  }

  public void handleError() {
    GLenum error = glGetError();
    if (error == GL_NO_ERROR) return;
    closeSDL();
    throw new Exception("OpenGL error(" ~ to!string(error) ~ ")");
  }

  protected void setCaption(string name) {
    SDL_SetWindowTitle(_window, std.string.toStringz(name));
  }

  public static void setColor(float r, float g, float b) {
    glColor3f(r * brightness, g * brightness, b * brightness);
  }

  public static void setColor(float r, float g, float b, float a) {
    glColor4f(r * brightness, g * brightness, b * brightness, a);
  }

  public static void setClearColor(float r, float g, float b, float a) {
    glClearColor(r * brightness, g * brightness, b * brightness, a);
  }
}

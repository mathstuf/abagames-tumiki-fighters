set(util_sdl_srcs
    gamemanager.d
    input.d
    mainloop.d
    pad.d
    screen.d
    screen3d.d
    sdlexception.d
    sound.d
    texture.d)

add_library(tf_util_sdl STATIC
    ${util_sdl_srcs})
target_link_libraries(tf_util_sdl
    tf_util
    Derelict::opengl3
    Derelict::sdl2
    Derelict::util)

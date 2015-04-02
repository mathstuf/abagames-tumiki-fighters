set(util_srcs
    actor.d
    actorpool.d
    csv.d
    iterator.d
    logger.d
    prefmanager.d
    rand.d
    vector.d)

add_library(tf_util STATIC
    ${util_srcs})

add_subdirectory(bulletml)
add_subdirectory(sdl)

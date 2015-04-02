set(util_bulletml_srcs
    bullet.d
    bulletsmanager.d)

add_library(tf_util_bulletml STATIC
    ${util_bulletml_srcs})
target_link_libraries(tf_util_bulletml
    tf_util
    BulletML::bulletml)

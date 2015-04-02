/*
 * $Id: morphbullet.d,v 1.3 2004/05/14 14:35:37 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.tf.morphbullet;

private import bml = bulletml.bulletml;
private import abagames.util.bulletml.bullet;

/**
 * Bullet with the bulletsmorph.
 */
public class MorphBullet: Bullet {
 public:
  static const int MORPH_MAX = 8;
  bml.ResolvedBulletML parser[MORPH_MAX];
  float[MORPH_MAX] ranks;
  float[MORPH_MAX] speeds;
  size_t morphNum;
  size_t morphIdx;
 private:

  public this(int id) {
    super(id);
  }

  public void setMorph(bml.ResolvedBulletML p[], float[] r, float[] s, size_t mn, size_t mi) {
    morphNum = mn;
    morphIdx = mi;
    for (size_t i = 0; i < mn; i++) {
      parser[i] = p[i];
      ranks[i] = r[i];
      speeds[i] = s[i];
    }
  }

  public bml.ResolvedBulletML getParser() {
    return parser[morphIdx];
  }

  public void resetMorph() {
    morphIdx = 0;
  }
}

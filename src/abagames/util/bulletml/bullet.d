/*
 * $Id: bullet.d,v 1.2 2004/05/14 14:35:38 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.bulletml.bullet;

private import std.math;
private import bml = bulletml.bulletml;
private import abagames.util.vector;
private import abagames.util.rand;
private import abagames.util.bulletml.bulletsmanager;

/**
 * Bullet controled by BulletML.
 */
public class Bullet: bml.BulletManager {
 public:
  static Vector activeTarget;
  Vector pos, acc;
  float deg;
  float speed;
  int id;
 private:
  static Rand randSource;
  static BulletsManager manager;
  const float VEL_SS_SDM_RATIO = 62.0 / 10;
  const float VEL_SDM_SS_RATIO = 10.0 / 62;
  bml.BulletMLRunner runner;
  float rankNum;

  public static init() {
    randSource = new Rand;
  }

  public static void setRandSeed(long s) {
    randSource.setSeed(s);
  }

  public static void setBulletsManager(BulletsManager bm) {
    manager = bm;
    activeTarget = new Vector;
    activeTarget.x = activeTarget.y = 0;
  }

  public void set(string name, bml.Value val) {
    assert(0);
  }

  public void remove(string name) {
    assert(0);
  }

  public bml.Value get(string name) {
    if (name == "rank") {
      return rank();
    } else if (name == "rand") {
      return rand();
    }

    assert(0);
  }

  public bml.Value rank() {
    return rankNum;
  }

  public bml.Value rand() {
    return randSource.nextFloat(1);
  }

  public void createSimpleBullet(double deg, double speed) {
    manager.addBullet(this, dtor(deg), speed * VEL_SDM_SS_RATIO);
  }

  public void createBullet(const bml.ResolvedBulletML state, double deg, double speed) {
    manager.addBullet(this, state, dtor(deg), speed * VEL_SDM_SS_RATIO);
  }

  public uint getTurn() {
    return manager.getTurn();
  }

  public double getDirection() {
    return rtod(deg);
  }

  public double getAimDirection() {
    Vector b = pos;
    Vector t = activeTarget;
    return rtod(std.math.atan2(t.x - b.x, t.y - b.y));
  }

  public double getSpeed() {
    return speed * VEL_SS_SDM_RATIO;
  }

  public double getDefaultSpeed() {
    return 1;
  }

  public void vanish() {
    kill();
  }

  public void changeDirection(double d) {
    deg = dtor(d);
  }

  public void changeSpeed(double s) {
    speed = s * VEL_SDM_SS_RATIO;
  }

  public void accelX(double sx) {
    acc.x = sx * VEL_SDM_SS_RATIO;
  }

  public void accelY(double sy) {
    acc.y = sy * VEL_SDM_SS_RATIO;
  }

  public double getSpeedX() {
    return acc.x;
  }

  public double getSpeedY() {
    return acc.y;
  }

  public this(int id) {
    pos = new Vector;
    acc = new Vector;
    this.id = id;
  }

  public void set(float x, float y, float deg, float speed, float rank) {
    pos.x = x; pos.y = y;
    acc.x = acc.y = 0;
    this.deg = deg;
    this.speed = speed;
    this.rankNum = rank;
    runner = null;
  }

  public void setRunner(bml.BulletMLRunner runner) {
    this.runner = runner;
  }

  public void set(bml.BulletMLRunner runner,
                  float x, float y, float deg, float speed, float rank) {
    set(x, y, deg, speed, rank);
    setRunner(runner);
  }

  public void move() {
    if (!runner.done()) {
      runner.run();
    }
  }

  public bool isEnd() {
    return runner.done();
  }

  public void kill() {
    manager.killMe(this);
  }

  public void remove() {
    if (runner) {
      runner = null;
    }
  }

  public float rank(float value) {
    return rankNum = value;
  }
}

public float rtod(float a) {
  return a * 180 / std.math.PI;
}

public float dtor(float a) {
  return a * std.math.PI / 180;
}

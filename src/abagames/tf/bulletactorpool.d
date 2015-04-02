/*
 * $Id: bulletactorpool.d,v 1.2 2004/05/14 14:35:37 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.tf.bulletactorpool;

private import bml = bulletml.bulletml;
private import abagames.util.actor;
private import abagames.util.actorpool;
private import abagames.util.bulletml.bullet;
private import abagames.util.bulletml.bulletsmanager;
private import abagames.tf.bulletinst;
private import abagames.tf.bulletactor;
private import abagames.tf.bullettarget;
private import abagames.tf.enemy;
private import abagames.tf.stagemanager;
private import abagames.tf.stuckenemy;

/**
 * Bullet actor pool that works as the BulletsManager.
 */
public class BulletActorPool: ActorPool, BulletsManager {
 private:
  int cnt;

  public this(int n, ActorInitializer ini) {
    scope BulletActor bulletActorClass = new BulletActor;
    super(n, bulletActorClass, ini);
    Bullet.setBulletsManager(this);
    BulletActor.init();
    cnt = 0;
  }

  public void setEnemies(EnemyPool enemies) {
    foreach (Actor a; actor)
      (cast(BulletActor) a).setEnemies(enemies);
  }

  public void setStageManager(StageManager stageManager) {
    foreach (Actor a; actor)
      (cast(BulletActor) a).setStageManager(stageManager);
  }

  public void addBullet(Bullet parent, float deg, float speed) {
    BulletActor ba = cast(BulletActor) getInstance();
    if (!ba)
      return;
    BulletInst rb = cast(BulletInst) parent;
    if (rb.deactivated)
      return;
    size_t nmi = rb.morphIdx + 1;
    BulletInst nbi = ba.bullet;
    if (nmi < rb.morphNum) {
      bml.BulletMLRunner runner = bml.createRunner(nbi, nbi.getParser());
      ba.set(runner, parent.pos.x, parent.pos.y, deg, speed,
             rb.ranks[nmi], rb.speeds[nmi],
             rb.shape, rb.color, rb.bulletSize, rb.xReverse, rb.yReverse, rb.target, rb.type,
             rb.parser, rb.ranks, rb.speeds, rb.morphNum, nmi);
      ba.setMorphSeed();
    } else {
      nmi--;
      ba.set(parent.pos.x, parent.pos.y, deg, speed,
             rb.ranks[nmi], rb.speeds[nmi],
             rb.shape, rb.color, rb.bulletSize, rb.xReverse, rb.yReverse, rb.target, rb.type);
    }
  }

  public void addBullet(Bullet parent, const bml.ResolvedBulletML state, float deg, float speed) {
    BulletActor ba = cast(BulletActor) getInstance();
    if (!ba)
      return;
    BulletInst rb = cast(BulletInst) parent;
    if (rb.deactivated)
      return;
    BulletInst nbi = ba.bullet;
    bml.BulletMLRunner runner = bml.createRunner(nbi, state);
    ba.set(runner, parent.pos.x, parent.pos.y, deg, speed,
           rb.ranks[rb.morphIdx], rb.speeds[rb.morphIdx],
           rb.shape, rb.color, rb.bulletSize, rb.xReverse, rb.yReverse, rb.target, rb.type,
           rb.parser, rb.ranks, rb.speeds, rb.morphNum, rb.morphIdx);
  }

  public BulletActor addTopBullet(bml.ResolvedBulletML[] parser,
                                  float[] ranks, float[] speeds,
                                  float x, float y, float deg, float speed,
                                  int shape, int color, float size,
                                  float xReverse, float yReverse,
                                  BulletTarget target, int type,
                                  int prevWait, int postWait) {
    BulletActor ba = cast(BulletActor) getInstance();
    if (!ba)
      return null;
    BulletInst nbi = ba.bullet;
    bml.BulletMLRunner runner = bml.createRunner(nbi, parser[0]);
    ba.set(runner, x, y, deg, speed,
           ranks[0], speeds[0],
           shape, color, size, xReverse, yReverse, target, type,
           parser, ranks, speeds, parser.length, 0);
    ba.setWait(prevWait, postWait);
    ba.setTop();
    return ba;
  }

  public BulletActor addMoveBullet(bml.ResolvedBulletML parser, float speed,
                                   float x, float y, float deg, BulletTarget target) {
    BulletActor ba = cast(BulletActor) getInstance();
    if (!ba)
      return null;
    BulletInst nbi = ba.bullet;
    bml.BulletMLRunner runner = bml.createRunner(nbi, parser);
    ba.set(runner, x, y, deg, 0,
           0, speed,
           0, 0, 0, 1, 1, target, BulletInst.Type.MOVE,
           null, null, null, 0, 0);
    ba.setInvisible();
    return ba;
  }

  public override void move() {
    super.move();
    cnt++;
  }

  public void drawShots() {
    foreach (Actor ac; actor)
      if (ac.isExist) {
        BulletActor ba = cast(BulletActor) ac;
        if (ba.bullet.type == BulletInst.Type.SHIP)
          ac.draw();
      }
  }

  public void drawBullets() {
    foreach (Actor ac; actor)
      if (ac.isExist) {
        BulletActor ba = cast(BulletActor) ac;
        if (ba.bullet.type == BulletInst.Type.ENEMY)
          ac.draw();
      }
  }

  public int getTurn() {
    return cnt;
  }

  public void killMe(Bullet bullet) {
    assert((cast(BulletActor) actor[bullet.id]).bullet.id == bullet.id);
    (cast(BulletActor) actor[bullet.id]).remove();
  }

  public override void clear() {
    foreach (Actor ac; actor) {
      if (ac.isExist)
        (cast(BulletActor) ac).removeForced();
    }
  }

  public void clearVisible() {
    foreach (Actor ac; actor) {
      if (ac.isExist)
        (cast(BulletActor) ac).removeForcedVisible();
    }
  }

  public void clearVisibleEnemy() {
    foreach (Actor ac; actor) {
      if (ac.isExist)
        (cast(BulletActor) ac).removeForcedVisibleEnemy();
    }
  }

  public void clearStuckEnemyHit(StuckEnemy se) {
    se.setWideCollision();
    foreach (Actor ac; actor) {
      if (ac.isExist) {
        BulletActor ba = cast(BulletActor) ac;
        if (se.checkHit(ba.bullet.pos)) {
          ba.removeForcedVisible();
        }
      }
    }
  }
}

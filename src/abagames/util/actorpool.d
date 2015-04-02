/*
 * $Id: actorpool.d,v 1.2 2004/05/14 14:35:38 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.actorpool;

private import abagames.util.actor;

/**
 * Object pooling for actors.
 */
public class ActorPool {
 public:
  Actor[] actor;
 protected:
  size_t actorIdx;

  public this(int n, Actor act, ActorInitializer ini) {
    actor = new Actor[n];
    foreach (ref Actor a; actor) {
      a = act.newActor();
      a.isExist = false;
      a.init(ini);
    }
    actorIdx = n;
  }

  public Actor getInstance() {
    for (size_t i = 0; i < actor.length; i++) {
      nextActor();
      if (!actor[actorIdx].isExist)
        return actor[actorIdx];
    }
    return null;
  }

  public Actor getInstanceForced() {
    nextActor();
    return actor[actorIdx];
  }

  public void move() {
    foreach (Actor ac; actor) {
      if (ac.isExist)
        ac.move();
    }
  }

  public void draw() {
    foreach (Actor ac; actor) {
      if (ac.isExist)
        ac.draw();
    }
  }

  public void clear() {
    foreach (Actor ac; actor) {
      ac.isExist = false;
    }
  }

  private void nextActor() {
    if (actorIdx == 0)
      actorIdx = actor.length - 1;
    else
      actorIdx--;
  }
}

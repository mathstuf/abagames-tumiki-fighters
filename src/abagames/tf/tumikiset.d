/*
 * $Id: tumikiset.d,v 1.2 2004/05/14 14:35:38 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.tf.tumikiset;

private import core.stdc.stdlib;
private import std.string;
private import std.math;
private import abagames.util.vector;
private import abagames.util.csv;
private import abagames.util.iterator;
private import abagames.util.logger;
private import abagames.util.actorpool;
private import abagames.tf.tumiki;
private import abagames.tf.bulletactor;
private import abagames.tf.bulletactorpool;
private import abagames.tf.enemy;
private import abagames.tf.bullettarget;
private import abagames.tf.fragment;

/**
 * Manage the set of tumikis.
 */
public class TumikiSet {
 public:
  Tumiki[] tumiki;
  int score, fireScore, fireScoreInterval;
  float sizeXm, sizeXp, sizeYm, sizeYp, size;
 private:
  static TumikiSet[string] instances;
  static const string TUMIKI_DIR_NAME = "tumiki";
  static const float BULLET_SPEED_RATIO = 1.2;
  static int[string] shapeStr;
  static string[] SHAPE_STR =
    ["s", "ul", "ur", "dr", "dl", "u", "r", "d", "l", "pu", "pdr", "pr", "pur", "pd", "pf"];
  static int[string] colorStr;
  static string[] COLOR_STR =
    ["r", "g", "b", "y", "p", "a", "w", "gr"];
  static int[string] bulletShapeStr;
  static string[] BULLET_SHAPE_STR =
    ["b", "a", "r"];
  static int[string] bulletColorStr;
  static string[] BULLET_COLOR_STR =
    ["r", "a", "p"];

  public static init() {
    int i = 0;
    foreach (string s; SHAPE_STR) {
      shapeStr[s] = i;
      i++;
    }
    i = 0;
    foreach (string s; COLOR_STR) {
      colorStr[s] = i;
      i++;
    }
    i = 0;
    foreach (string s; BULLET_SHAPE_STR) {
      bulletShapeStr[s] = i;
      i++;
    }
    i = 0;
    foreach (string s; BULLET_COLOR_STR) {
      bulletColorStr[s] = i;
      i++;
    }
  }

  // Initialize TumikiSet with the array.
  // sizeRatio,
  // score, fireScore, fireScoreInterval,
  // [shape, color, x, y, sizex, sizey,
  //  [shape, color, size, yReverse, prevWait, postWait,
  //   [BulletML, rank, speed]],
  //  (end when BulletML == e, shape == e)(set a empty barrage when shape == s),
  // ],
  private this(string[] data) {
    sizeXm = sizeYm = float.max;
    sizeXp = sizeYp = float.min;
    StringIterator si = new StringIterator(data);
    float sizeRatio = atof(si.next.ptr);
    score = atoi(si.next.ptr);
    fireScore = atoi(si.next.ptr);
    fireScoreInterval = atoi(si.next.ptr);
    for (;;) {
      if (!si.hasNext)
        break;
      string v = si.next;
      int shape = shapeStr[v];
      v = si.next;
      int color = colorStr[v];
      float x = atof(si.next.ptr);
      float y = atof(si.next.ptr);
      float sizex = atof(si.next.ptr);
      float sizey = atof(si.next.ptr);
      Tumiki ti = new Tumiki(shape, color, x, y, sizex, sizey, sizeRatio);
      if (sizeXp < ti.ofs.x + ti.size.x)
        sizeXp = ti.ofs.x + ti.size.x;
      if (sizeXm > ti.ofs.x - ti.size.x)
        sizeXm = ti.ofs.x - ti.size.x;
      if (sizeYp < ti.ofs.y + ti.size.y)
        sizeYp = ti.ofs.y + ti.size.y;
      if (sizeYm > ti.ofs.y - ti.size.y)
        sizeYm = ti.ofs.y - ti.size.y;
      for (;;) {
        v = si.next;
        if (v == "e") {
          break;
        } else if (v == "s") {
          ti.addBarrage(new Barrage);
          continue;
        }
        int bulletShape = bulletShapeStr[v];
        v = si.next;
        int bulletColor = bulletColorStr[v];
        float size = atof(si.next.ptr);
        float yReverse = atof(si.next.ptr);
        int prevWait = atoi(si.next.ptr);
        int postWait = atoi(si.next.ptr);
        Barrage br = new Barrage
          (bulletShape, bulletColor, size, yReverse, prevWait, postWait);
        for (;;) {
          string bml = si.next;
          if (bml == "e")
            break;
          float rank = atof(si.next.ptr);
          float speed = atof(si.next.ptr);
          br.addBml(bml, rank, speed * BULLET_SPEED_RATIO);
        }
        ti.addBarrage(br);
      }
      tumiki ~= ti;
    }
    size = -sizeXm + sizeXp - sizeYm + sizeYp;
  }

  // Initialize TumikiSet from the file.
  public this(string fileName) {
    Logger.info("Load tumiki set: " ~ fileName);
    string[] data = CSVTokenizer.readFile(TUMIKI_DIR_NAME ~ "/" ~ fileName);
    this(data);
  }

  public static TumikiSet getInstance(string fileName) {
    TumikiSet* pinst = fileName in instances;
    TumikiSet inst;
    if (inst is null) {
      inst = new TumikiSet(fileName);
      instances[fileName] = inst;
    } else {
      inst = *pinst;
    }
    return inst;
  }

  public int addTopBullets(int barragePtnIdx, BulletActorPool bullets, EnemyTopBullet[] etb,
                           BulletTarget target, int type) {
    int etbIdx = 0;
    foreach (Tumiki t; tumiki) {
      BulletActor ba = t.addTopBullet(barragePtnIdx, bullets, target, type);
      if (ba) {
        etb[etbIdx].actor = ba;
        etb[etbIdx].tumiki = t;
        etb[etbIdx].deactivated = false;
        etbIdx++;
      }
    }
    return etbIdx;
  }

  public void breakIntoFragments(ActorPool fragments, float x, float y, float d) {
    foreach (Tumiki t; tumiki) {
      float ox = t.ofs.x * cos(d) - t.ofs.y * sin(d);
      float oy = t.ofs.x * sin(d) + t.ofs.y * cos(d);
      Fragment fr = cast(Fragment) fragments.getInstanceForced();
      fr.set(t.shape, t.color, x + ox, y + oy, t.size);
    }
  }

  public void breakIntoFragments(ActorPool fragments, Vector pos, float d) {
    breakIntoFragments(fragments, pos.x, pos.y, d);
  }

  public void draw(Vector pos, float z, float deg) {
    foreach (Tumiki t; tumiki)
      t.draw(pos, z, 0, deg);
  }

  public void drawShade(Vector pos, float z, int shade, float deg) {
    foreach (Tumiki t; tumiki)
      t.draw(pos, z, shade, deg);
  }

  public void drawShade(Vector pos, float z, int shade, float deg, float size) {
    foreach (Tumiki t; tumiki)
      t.draw(pos, z, shade, deg, size);
  }

  public void draw(Vector pos, float z) {
    foreach (Tumiki t; tumiki)
      t.draw(pos, z, 0);
  }

  public void drawShade(Vector pos, float z, int shade) {
    foreach (Tumiki t; tumiki)
      t.draw(pos, z, shade);
  }

  public void draw(float x, float y, float z, bool damaged, bool wounded) {
    foreach (Tumiki t; tumiki)
      t.draw(x, y, z, 0, damaged, wounded);
  }

  public bool checkHit(Vector p, float x, float y) {
    foreach (Tumiki t; tumiki)
      if (t.checkHit(p, x, y))
        return true;
    return false;
  }
}

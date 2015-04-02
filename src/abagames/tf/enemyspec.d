/*
 * $Id: enemyspec.d,v 1.2 2004/05/14 14:35:37 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.tf.enemyspec;

private import core.stdc.stdlib;
private import std.string;
private import abagames.util.vector;
private import abagames.util.csv;
private import abagames.util.iterator;
private import abagames.util.logger;
private import abagames.tf.tumikiset;

/**
 * Enemy specs built by tumikis.
 */
public class EnemySpec {
 public:
  EnemyPartSpec[] parts;
  AttackForm[] attackForm;
  float sizeXm, sizeXp, sizeYm, sizeYp;
 private:
  static EnemySpec[string] instances;
  static const string ENEMYSPEC_DIR_NAME = "enemy";

  // Initialize EnemySpec with the array.
  // Tumiki file name(main),
  // [shield, [attackPeriod, breakPeriod]],
  // (end when breakPeriod == e, shield == e)
  // [Tumiki file name(part), x, y, shield, destroyedFormIdx, damageToMainBody],
  private this(string[] data) {
    StringIterator si = new StringIterator(data);
    string fn = si.next;
    EnemyPartSpec bodySpec = new EnemyPartSpec(fn);
    parts ~= bodySpec;
    bool bodyShieldSet = false;
    int ai = 0;
    for (;;) {
      string v = si.next;
      if (v == "e")
        break;
      float shield = atof(v.ptr);
      if (!bodyShieldSet) {
        bodySpec.shield = shield;
        bodyShieldSet = true;
      }
      AttackForm af = new AttackForm(shield, ai);
      for (;;) {
        v = si.next;
        if (v == "e")
          break;
        int attackPeriod = atoi(v.ptr);
        int breakPeriod = atoi(si.next.ptr);
        af.addPeriod(attackPeriod, breakPeriod);
        ai++;
      }
      attackForm ~= af;
    }
    for (;;) {
      if (!si.hasNext)
        break;
      fn = si.next;
      float x = atof(si.next.ptr);
      float y = atof(si.next.ptr);
      float shield = atof(si.next.ptr);
      int dfi = atoi(si.next.ptr);
      float dtm = atof(si.next.ptr);
      EnemyPartSpec tp = new EnemyPartSpec(fn, x, y, shield, dfi, dtm);
      parts ~= tp;
    }
    sizeXm = sizeYm = float.max;
    sizeXp = sizeYp = float.min;
    foreach (EnemyPartSpec eps; parts) {
      if (sizeXp < eps.ofs.x + eps.tumikiSet.sizeXp)
        sizeXp = eps.ofs.x + eps.tumikiSet.sizeXp;
      if (sizeXm > eps.ofs.x + eps.tumikiSet.sizeXm)
        sizeXm = eps.ofs.x + eps.tumikiSet.sizeXm;
      if (sizeYp < eps.ofs.y + eps.tumikiSet.sizeYp)
        sizeYp = eps.ofs.y + eps.tumikiSet.sizeYp;
      if (sizeYm > eps.ofs.y + eps.tumikiSet.sizeYm)
        sizeYm = eps.ofs.y + eps.tumikiSet.sizeYm;
    }
  }

  private this(string fileName) {
    string[] data = CSVTokenizer.readFile(ENEMYSPEC_DIR_NAME ~ "/" ~ fileName);
    this(data);
  }

  public static EnemySpec getInstance(string fileName) {
    EnemySpec* pinst = fileName in instances;
    EnemySpec inst;
    if (pinst is null) {
      Logger.info("Load enemy spec: " ~ fileName);
      inst = new EnemySpec(fileName);
      instances[fileName] = inst;
    } else {
      inst = *pinst;
    }
    return inst;
  }
}

public class EnemyPartSpec {
 public:
  TumikiSet tumikiSet;
  Vector ofs;
  float shield;
  int destroyedFormIdx;
  float damageToMainBody;

 private:

  public this(string fileName) {
    tumikiSet = TumikiSet.getInstance(fileName);
    ofs = new Vector;
    destroyedFormIdx = 99999;
    damageToMainBody = 0;
  }

  public this(string fileName, float x, float y) {
    this(fileName);
    ofs.x = x;
    ofs.y = y;
  }

  public this(string fileName, float x, float y, float s, int dfi, float dtm) {
    this(fileName, x, y);
    shield = s;
    destroyedFormIdx = dfi;
    damageToMainBody = dtm;
  }
}

public class AttackForm {
 public:
  float shield;
  int barragePtnStartIdx;
  int[] attackPeriod;
  int[] breakPeriod;

 private:

  public this(float s, int bpi) {
    shield = s;
    barragePtnStartIdx = bpi;
  }

  public void addPeriod(int ap, int bp) {
    attackPeriod ~= ap;
    breakPeriod ~= bp;
  }
}


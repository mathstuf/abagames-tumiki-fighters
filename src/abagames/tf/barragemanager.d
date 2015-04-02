/*
 * $Id: barragemanager.d,v 1.3 2004/05/14 14:35:37 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.tf.barragemanager;

private import std.string;
private import std.path;
private import std.file;
private import bml = bulletml.bulletml;
private import abagames.util.logger;
private import abagames.tf.morphbullet;

/**
 * Barrage manager(BulletMLs' loader).
 */
public class BarrageManager {
 private:
  static bml.ResolvedBulletML parser[string];
  static const string BARRAGE_DIR_NAME = "barrage";

  public static void loadBulletMLs() {
    foreach (string dirPath; dirEntries(BARRAGE_DIR_NAME, SpanMode.shallow)) {
      if (!isDir(dirPath)) {
        continue;
      }
      string dirName = baseName(dirPath);
      foreach (string filePath; dirEntries(dirPath, "*.xml", SpanMode.shallow)) {
        string fileName = baseName(filePath);
        parser[dirName ~ "/" ~ fileName] = loadInstance(filePath);
      }
    }
  }

  private static bml.ResolvedBulletML loadInstance(string path) {
    Logger.info("Load BulletML: " ~ path);
    return bml.resolve(bml.parse(path));
  }

  public static bml.ResolvedBulletML getInstance(string fileName) {
    return parser[fileName];
  }
}

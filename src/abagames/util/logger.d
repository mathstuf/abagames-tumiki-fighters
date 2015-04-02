/*
 * $Id: logger.d,v 1.3 2004/05/14 14:35:38 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.logger;

private import std.conv;
private import std.cstream;
private import std.string;

/**
 * Logger(error/info).
 */
version(Windows) {

import std.string;
import std.c.windows.windows;

public class Logger {

  public static void info(string msg) {
    // Win32 exe file crashes if it writes something to stderr.
    //stderr.writeLine("Info: " ~ msg);
  }

  public static void info(int n) {
    //stderr.writeLine("Info: " ~ std.string.toString(n));
  }

  public static void info(float n) {
    //stderr.writeLine("Info: -" ~ std.string.toString(n));
  }

  private static void putMessage(string msg) {
    MessageBoxA(null, std.string.toStringz(msg), "Error", MB_OK | MB_ICONEXCLAMATION);
  }

  public static void error(string msg) {
    putMessage("Error: " ~ msg);
  }

  public static void error(Exception e) {
    putMessage("Error: " ~ e.toString());
  }

  public static void error(Error e) {
    putMessage("Error: " ~ e.toString());
  }
}

} else {

public class Logger {

  public static void info(string msg) {
    std.cstream.derr.writeLine("Info: " ~ msg);
  }

  public static void info(int n) {
    std.cstream.derr.writeLine("Info: " ~ to!string(n));
  }

  public static void info(float n) {
    std.cstream.derr.writeLine("Info: -" ~ to!string(n));
  }

  public static void error(string msg) {
    std.cstream.derr.writeLine("Error: " ~ msg);
  }

  public static void error(Exception e) {
    std.cstream.derr.writeLine("Error: " ~ e.toString());
  }

  public static void error(Error e) {
    std.cstream.derr.writeLine("Error: " ~ e.toString());
    if (e.next)
      error(to!Exception(e.next));
  }
}

}

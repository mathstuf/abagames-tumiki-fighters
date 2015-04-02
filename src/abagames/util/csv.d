/*
 * $Id: csv.d,v 1.2 2004/05/14 14:35:38 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.util.csv;

private import std.stream;
private import std.string;

/**
 * CSV format Tokenizer.
 */
public class CSVTokenizer {
 private:

  public static string[] readFile(string fileName) {
    string[] result;
    scope File fd = new File;
    fd.open(fileName);
    for (;;) {
      char[] line = fd.readLine();
      if (!line)
        break;
      char[][] spl = split(line, ",");
      foreach (char[] s; spl) {
        char[] r = strip(s);
        if (r.length > 0)
          result ~= r.idup;
      }
    }
    fd.close();
    return result;
  }
}

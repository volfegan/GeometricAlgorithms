/**
 * Point class to hold points
 * @author Volfegan [Daniel L Lacerda]
 * 
 */

public class Point implements Comparable<Point> {
  public double x;
  public double y;
  public Segment data; //data reference from object

  public Point () {
    this.x = 0;
    this.y = 0;
    this.data = null;
  }
  public Point (double x, double y) {
    this.x = x;
    this.y = y;
    this.data = null;
  }
  public Point (double x, double y, Segment s) {
    this.x = x;
    this.y = y;
    this.data = s;
  }

  public double getX() {
    return this.x;
  }

  public double getY() {
    return this.y;
  }

  public Segment getData() {
    return this.data;
  }

  public boolean equals(Point p) {
    if (this.x == p.x && this.y == p.y)
      return true;
    else
      return false;
  }

  public int compareTo(Point p) {
    int H1 = 0x8da6b343; //an arbitrarily chosen prime
    
    if (this.x * H1 + this.y > p.x * H1 + p.y) {
      return 1;
    }
    if (this.x * H1 + this.y < p.x * H1 + p.y) {
      return -1;
    }
    return 0;
  }

  public String toString() {
    return "(" + this.x + " " + this.y + ")";
  }
}

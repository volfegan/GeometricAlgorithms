/**
 * Segment class to hold segments
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
public class Segment {
  Point a;
  Point b;

  Segment() {
    a = new Point();
    b = new Point();
  }
  Segment(int x0, int y0, int x1, int y1) {
    this.a = new Point(x0, y0);
    this.b = new Point(x1, y1);
  }
  Segment(Point a, Point b) {
    this.a = a;
    this.b = b;
  }

  public String toString() {
    String s = a.toString() + " " + b.toString();
    return s;
  }

  /*
   * calculates the intersection point
   * 
   * @param Segment s
   * @return Point intersect
   */
  public Point intersect(Segment s) {
    Point intersect = new Point();
    if (this == null || s == null) {
      return null;
    }
    //calculate the intersection point (x, y)
    intersect.x = ((s.a.x * s.b.y - s.a.y * s.b.x)
      * (this.a.x - this.b.x) - (s.a.x - s.b.x)
      * (this.a.x * this.b.y - this.a.y * this.b.x))
      / ((s.a.x - s.b.x) * (this.a.y - this.b.y) - (s.a.y - s.b.y)
      * (this.a.x - this.b.x));
    intersect.y = ((s.a.x * s.b.y - s.a.y * s.b.x)
      * (this.a.y - this.b.y) - (s.a.y - s.b.y)
      * (this.a.x * this.b.y - this.a.y * this.b.x))
      / ((s.a.x - s.b.x) * (this.a.y - this.b.y) - (s.a.y - s.b.y)
      * (this.a.x - this.b.x));

    if (outOfRange(intersect, s) || outOfRange(intersect, this)
      || Double.isNaN(intersect.x) || Double.isNaN(intersect.x)) {
      intersect = null;
    }

    if (intersect != null) {
      //rounding to 2 decimal places
      intersect.x = Math.round(intersect.x * 100.0) / 100.0;
      intersect.y = Math.round(intersect.y * 100.0) / 100.0;
    }
    return intersect;
  }

  /*
   * checks if intersection point is within segment range.
   * @param Point p
   * @param Segment s
   * @return boolean
   */
  boolean outOfRange(Point p, Segment s) {
    if ((p.x < s.a.x && p.x < s.b.x) || (p.x > s.a.x && p.x > s.b.x)
      || (p.y < s.a.y && p.y < s.b.y) || (p.y > s.a.y && p.y > s.b.y)) {
      return true;
    } else
      return false;
  }
}

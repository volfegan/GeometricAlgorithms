/*
 * Segment class to hold segments made of Points a & b
 * and a point_value
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
public class Segment implements Comparable<Segment> {
  private Point a; //always the left point (lower x value)
  private Point b;
  private double value; //'y' value calculated from a 'x' the segment line equation

  Segment() {
    this.a = new Point();
    this.b = new Point();
    this.value = 0;
  }
  Segment(int x0, int y0, int x1, int y1) {
    a = new Point(x0, y0);
    b = new Point(x1, y1);
    Segment s = new Segment(a, b);
    this.a = s.a;
    this.b = s.b;
    this.value = s.value;
  }
  //construct the segment lines with lower x (on left) as start points 'a'
  Segment(Point a, Point b) {
    if (a.get_x() < b.get_x()) {
      this.a = a;
      this.b = b;
    }
    if (b.get_x() < a.get_x()) {
      this.a = b;
      this.b = a;
    }
    if (a.get_x() == b.get_x()) {
      if (a.get_y() < b.get_y()) {
        this.a = a;
        this.b = b;
      } else {
        this.a = b;
        this.b = a;
      }
    }
    this.calculate_value(this.startPoint().get_x());
  }
  //return the most low x Point (left position), that is 'a', but I'll test again
  public Point startPoint() {
    if (a.get_x() <= b.get_x()) {
      return a;
    } else {
      return b;
    }
  }
  //return the most high x Point (right position), that is 'b', but test for sure
  public Point endPoint() {
    if (a.get_x() <= b.get_x()) {
      return b;
    } else {
      return a;
    }
  }
  //calculate a y value from the line equation extracted from the segment
  //the value is used to position the segment on statusT and eventQ
  public void calculate_value(double old_value) {
    double x0 = this.startPoint().get_x();
    double y0 = this.startPoint().get_y();
    double x1 = this.endPoint().get_x();
    double y1 = this.endPoint().get_y();
    //works only if the density of lines are not big. I don't know a better way to implement a robust formula
    this.value = y0 + (((y1 - y0) / (x1 - x0)) * (old_value - x0));
  }
  
  public Point get_a() {
    return this.a;
  }
  
  public Point get_b() {
    return this.b;
  }

  

  public void set_value(double value) {
    this.value = value;
  }

  public double get_value() {
    return this.value;
  }

  public String toString() {
    String s = a.toString() + "->" + b.toString();
    return s;
  }

  public int compareTo(Segment s) {
    if (this.get_value() < s.get_value()) {
      return 1;
    }
    if (this.get_value() > s.get_value()) {
      return -1;
    }
    return 0;
  }
  
  //some segment is equal to another if their points are equal, no matter the order of points a, b
  public boolean equals(Object segment) {
    Segment s = (Segment) segment;
    if ((this.a.equals(s.a) && this.b.equals(s.b)) ||
      (this.a.equals(s.b) && this.b.equals(s.a)))
      return true;
    else
      return false;
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

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
    if (a.getX() < b.getX()) {
      this.a = a;
      this.b = b;
    }
    if (b.getX() < a.getX()) {
      this.a = b;
      this.b = a;
    }
    if (a.getX() == b.getX()) {
      if (a.getY() < b.getY()) {
        this.a = a;
        this.b = b;
      } else {
        this.a = b;
        this.b = a;
      }
    }
    this.calculate_value(this.startPoint().getX());
  }
  //return the most low x Point (left position), that is 'a', but I'll test again
  public Point startPoint() {
    if (a.getX() <= b.getX()) {
      return a;
    } else {
      return b;
    }
  }
  //return the most high x Point (right position), that is 'b', but test for sure
  public Point endPoint() {
    if (a.getX() <= b.getX()) {
      return b;
    } else {
      return a;
    }
  }
  //calculate a y value from the line equation extracted from the segment
  //the value is used to position the segment on statusT and eventQ
  public double calculate_value(double old_value) {
    double x0 = this.startPoint().getX();
    double y0 = this.startPoint().getY();
    double x1 = this.endPoint().getX();
    double y1 = this.endPoint().getY();
    //works only if the density of lines are not big. I don't know a better way to implement a robust formula
    this.value = y0 + (((y1 - y0) / (x1 - x0)) * (old_value - x0));
    return this.value;
  }

  /*
   * calculates a point inside both the rectangle range and the segment line itself
   * 
   * @param Rectangle range
   * @return Point p inside the segment with refrence to itself or null
   */
  public Point createPointIn(Rectangle range) {
    Point p = null;
    Point a = this.startPoint();
    Point b = this.endPoint();
    Point intersect1 = null, intersect2 = null; //points from the segment that intersects the Rectangle range
    double pX, pY;

    //Check if segment end points (a,b) are inside this Rectangle range
    if (range.contains(a)) return new Point(a.getX(), a.getY(), this); 
    if (range.contains(b)) return new Point(b.getX(), b.getY(), this); 

    //get the 4 Point corners (c,d,e,f) of this rectangle range coordenates
    double leftX = range.x - range.width;
    double rightX = range.x + range.width;
    double topY = range.y - range.height;
    double bottomY = range.y + range.height;
    Point c = new Point(leftX, topY);     //top left
    Point d = new Point(rightX, topY);    //top right
    Point e = new Point(leftX, bottomY);  //bottom left
    Point f = new Point(rightX, bottomY); //bottom right
    //get the 4 segments from the 4 Points corners
    Segment top = new Segment(c, d);
    Segment bottom = new Segment(e, f);
    Segment left = new Segment(c, e);
    Segment right = new Segment(d, f);

    //there are 6 ways to the segment pass through the rectangle range
    //        2             4
    //        |       3      \              5       6
    //     ___|___     \  ____\__         _/_____  /
    //    |   |   |     \|     \ |       |/      |/
    // 1--|-------|--    |   .  \|       |   .   |
    //    |   |   |      |\      |      /|      /|
    //     ---|---        ------- \    /  -------  
    //        |             \                 /
    intersect1 = this.intersect(left);
    intersect2 = this.intersect(right);
    if (intersect1 != null && intersect2 != null) {
      //System.out.println("1.("+intersect1+"; "+intersect2+")");
      pX = (intersect1.getX() + intersect2.getX())/2;
      pY = (intersect1.getY() + intersect2.getY())/2;
      p = new Point(pX, pY, this);
      return p;
    }
    intersect1 = this.intersect(bottom);
    intersect2 = this.intersect(top);
    if (intersect1 != null && intersect2 != null) {
      //System.out.println("2.("+intersect1+"; "+intersect2+")");
      pX = (intersect1.getX() + intersect2.getX())/2;
      pY = (intersect1.getY() + intersect2.getY())/2;
      p = new Point(pX, pY, this);
      return p;
    }
    intersect1 = this.intersect(left);
    intersect2 = this.intersect(bottom);
    if (intersect1 != null && intersect2 != null) {
      //System.out.println("3.("+intersect1+"; "+intersect2+")");
      pX = (intersect1.getX() + intersect2.getX())/2;
      pY = (intersect1.getY() + intersect2.getY())/2;
      p = new Point(pX, pY, this);
      return p;
    }
    intersect1 = this.intersect(top);
    intersect2 = this.intersect(right);
    if (intersect1 != null && intersect2 != null) {
      //System.out.println("4.("+intersect1+"; "+intersect2+")");
      pX = (intersect1.getX() + intersect2.getX())/2;
      pY = (intersect1.getY() + intersect2.getY())/2;
      p = new Point(pX, pY, this);
      return p;
    }
    intersect1 = this.intersect(left);
    intersect2 = this.intersect(top);
    if (intersect1 != null && intersect2 != null) {
      //System.out.println("5.("+intersect1+"; "+intersect2+")");
      pX = (intersect1.getX() + intersect2.getX())/2;
      pY = (intersect1.getY() + intersect2.getY())/2;
      p = new Point(pX, pY, this);
      return p;
    }
    intersect1 = this.intersect(right);
    intersect2 = this.intersect(bottom);
    if (intersect1 != null && intersect2 != null) {
      //System.out.println("6.("+intersect1+"; "+intersect2+")");
      pX = (intersect1.getX() + intersect2.getX())/2;
      pY = (intersect1.getY() + intersect2.getY())/2;
      p = new Point(pX, pY, this);
      return p;
    }
    return null;
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
  public boolean outOfRange(Point p, Segment s) {
    if ((p.x < s.a.x && p.x < s.b.x) || (p.x > s.a.x && p.x > s.b.x)
      || (p.y < s.a.y && p.y < s.b.y) || (p.y > s.a.y && p.y > s.b.y)) {
      return true;
    } else
      return false;
  }
}

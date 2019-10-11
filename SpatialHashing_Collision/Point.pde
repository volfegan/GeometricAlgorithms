// Daniel Shiffman, modified and improved by Volfegan
// http://codingtra.in
// http://patreon.com/codingtrain
//Videos
//Part 1:
//https://www.youtube.com/watch?v=OJxEcs0w_kE
//Part 2: 
//https://www.youtube.com/watch?v=QQx_NmCIuCY
//Part 3: 
//https://www.youtube.com/watch?v=z0YFFg_nBjw


class Point implements Comparable<Point> {
  double x;
  double y;
  Object data; //data reference from object

  public Point (double x, double y) {
    this.x = x;
    this.y = y;
    this.data = null;
  }

  public Point (double x, double y, Object p) {
    this.x = x;
    this.y = y;
    this.data = p;
  }

  public double getX() {
    return this.x;
  }

  public double getY() {
    return this.y;
  }

  public Object getData() {
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

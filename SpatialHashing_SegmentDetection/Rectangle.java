// author Volfegan [Daniel L Lacerda] 
// This class was based at 
// http://codingtra.in QuadTree Videos
//Part 1: https://www.youtube.com/watch?v=OJxEcs0w_kE
//Part 2: https://www.youtube.com/watch?v=QQx_NmCIuCY
//Part 3: https://www.youtube.com/watch?v=z0YFFg_nBjw

public class Rectangle {
  public double x;
  public double y;
  public double height ; 
  public double width;

  /*Creates a Rectangle with a center on x, y
   * ___
   *| . | 2x height
   * ---
   * 2x width
   */
  public Rectangle (double x, double y, double width, double height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  /*
   * Checks if this Rectangle object intersects with a rectangle range
   */
  public boolean intersects(Rectangle range) {
    return !(range.x - range.width > this.x + this.width ||
      range.x + range.width < this.x - this.width ||
      range.y - range.height > this.y + this.height ||
      range.y + range.height < this.y - this.height);
  }

  public boolean contains(Point p) {
    return  p.x <= this.x+this.width &&
      p.x >= this.x-this.width &&
      p.y <= this.y+this.height &&
      p.y >= this.y-this.height ;
  }

  /*
   * Checks if this Rectangle object contains a segment passing through it or inside
   * \___      _/_
   * |\. | or |/. |
   *  ---     /---
   */
  public boolean contains(Segment segment) {
    //get the 2 points (a,b) of segment
    Point a = segment.startPoint(); //most left point
    Point b = segment.endPoint(); //most right point   

    //Check if segment end points (a,b) are inside this Rectangle object
    if (this.contains(a) || this.contains(b)) return true; 

    //get the 4 Point corners (c,d,e,f) of this rectangle object coordenates
    double leftX = this.x - this.width;
    double rightX = this.x + this.width;
    double topY = this.y - this.height;
    double bottomY = this.y + this.height;
    Point c = new Point(leftX, topY);     //top left
    Point d = new Point(rightX, topY);    //top right
    Point e = new Point(leftX, bottomY);  //bottom left
    Point f = new Point(rightX, bottomY); //bottom right
    //get the 4 segments from the 4 Points corners
    Segment top = new Segment(c, d);
    Segment bottom = new Segment(e, f);
    Segment left = new Segment(c, e);
    Segment right = new Segment(d, f);
    
    return (segment.intersect(top) != null || segment.intersect(bottom) != null 
            || segment.intersect(left) != null || segment.intersect(right) != null);    
  }
}

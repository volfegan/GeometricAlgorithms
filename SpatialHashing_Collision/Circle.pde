// author Volfegan [Daniel L Lacerda] 
// This class was based at 
// http://codingtra.in QuadTree Videos
//Part 3: https://www.youtube.com/watch?v=z0YFFg_nBjw

import java.lang.Math;
//for a circle shape query
public class Circle {
  double x;
  double y;
  double r;
  double rSquared;

  public Circle(double x, double y, double r) {
    this.x = x;
    this.y = y;
    this.r = r; //radius of the circle
    this.rSquared = this.r * this.r;
  }

  public boolean intersects(Rectangle range) {
    double xDist = Math.abs(range.x - this.x);
    double yDist = Math.abs(range.y - this.y);

    double r = this.r;
    double w = range.width;
    double h = range.height;

    double edges = Math.pow( (xDist - w), 2 ) + Math.pow( (yDist - h), 2 );

    //no intersection
    if (xDist > (r + w) || yDist > (r + h)) return false;

    //intersection within the circle
    if (xDist <= w || yDist <= h) return true;

    //intersection on the edge of the circle
    return edges <= this.rSquared;
  }

  // check if the point is in the circle by measuring the euclidean distance of
  // the point and the center of the circle is smaller or equal than the radius 
  // of the circle
  public boolean contains (Point p) {
    double dist = Math.pow((p.x - this.x), 2) + Math.pow((p.y - this.y), 2);
    return dist <= this.rSquared;
  }
}

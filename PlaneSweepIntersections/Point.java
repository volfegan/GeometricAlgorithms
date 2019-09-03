/**
 * Point class to hold points with x, y coordinates
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
public class Point {
	public double x;
	public double y;

	Point() {
  this.x = 0;
  this.y = 0;
	}

	Point(int x, int y) {
		this.x = (double)x;
		this.y = (double)y;
	}

  Point(double x, double y) {
    this.x = x;
    this.y = y;
  }
  
  public double get_x() {
    return this.x;
  }
  
  public double get_y() {
    return this.y;
  }
  
  public void set_x(double new_x) {
    this.x = new_x;
  }
  
  public void set_y(double new_y) {
    this.y = new_y;
  }

	public String toString() {
		String p = "(" + x + ", " + y + ")";
		return p;
	}

	public boolean equals(Point p) {
		if (this.x == p.x && this.y == p.y)
			return true;
		else
			return false;
	}
}

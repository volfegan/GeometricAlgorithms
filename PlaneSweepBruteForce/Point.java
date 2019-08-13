/**
 * Point class to hold points
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
public class Point {
	double x;
	double y;

	Point() {
	}

	Point(int x, int y) {
		this.x = x;
		this.y = y;
	}

  Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

	public String toString() {
		String p = "(" + x + " " + y + ")";
		return p;
	}

	public boolean equals(Object s) {
		Point a = (Point) s;
		if (this.x ==a.x && this.y==a.y)
			return true;
		else
			return false;
	}
}

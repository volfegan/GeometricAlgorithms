/**
 * Class used to show the lines segment visualization in a colourful way on processing screen
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
//the Comparable is a requirement for usage of Binary Tree
public class Line implements Comparable<Line> {

  PVector a, b;
  double id;
  int alpha;

  Line(PVector a, PVector b, int alpha) {
    //we multiply a with b, each in the form of (x*width+y) to get a unique pair id
    this.id = (a.x*width+a.y)*(b.x*width+b.y);
    this.a = a;
    this.b = b;
    this.alpha = alpha;
  }

  public void display() {
    color c = color(a.x % 255, 255-a.y % 255, b.y % 255, this.alpha);
    strokeWeight(1);
    stroke(c);
    line(this.a.x, this.a.y, this.b.x, this.b.y);
  }

  public boolean equals(Line l) {
    if (this.id == l.id)
      return true;
    else
      return false;
  }

  //the compareTo is a requirement for usage of Binary Tree
  public int compareTo(Line l) {
    if (this.id > l.id) {
      return 1;
    }
    if (this.id < l.id) {
      return -1;
    }
    return 0;
  }
}

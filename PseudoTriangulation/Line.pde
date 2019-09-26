/**
 * Class used to show the lines segment visualization in a colourful way on processing screen
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
public class Line {

  PVector a, b;
  int alpha;

  Line(PVector a, PVector b, int alpha) {
    this.a = a;
    this.b = b;
    this.alpha = alpha;
  }

  void display() {
    color c = color(a.x % 255, 255-a.y % 255, b.y % 255, this.alpha);
    strokeWeight(1);
    stroke(c);
    line(this.a.x, this.a.y, this.b.x, this.b.y);
  }
}

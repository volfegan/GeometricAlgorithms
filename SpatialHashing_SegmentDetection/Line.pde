
/*
 * Class used to show the lines segment visualization in a colourful way on processing screen
 */
class Line {

  PVector a, b;

  Line(PVector a, PVector b) {

    this.a = a;
    this.b = b;
  }  

  void display() {
    color c = color(a.x % 255, 255-a.y % 255, b.y % 255);
    strokeWeight(1);
    stroke(c);
    line(this.a.x, this.a.y, this.b.x, this.b.y);
  }
}

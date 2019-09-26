/**
 * Point class to hold points using processing PVector
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
public class Point {
  public PVector p;
  public float dx, dy, lifespan;

  Point(int x, int y) {
    this.p = new PVector(x, y);
    this.dx = random(-1,1);
    this.dy = random(-1,1);
    this.lifespan = random(500, 1000);
  }

  Point(float x, float y) {
    this.p = new PVector(x, y);
    this.dx = random(-1,1);
    this.dy = random(-1,1);
    this.lifespan = random(500, 1000);
  }
  
  public PVector getPVector() {
    return this.p;
  }

  public float getX() {
    return this.p.x;
  }

  public float getY() {
    return this.p.y;
  }

  public String toString() {
    return "(" + this.p.x + " " + this.p.y + ")";
  }

  void display() {
    color c = color(p.x % 255, 255-p.y % 255, (p.x+p.y) % 255);
    if (this.lifespan > 50) strokeWeight(4);
    else {
      //the less lifespan, the bigger the point and more transparent
      int pointSize = round(map(this.lifespan, 50, 0, 4, 12));
      strokeWeight(pointSize);
      int alpha = round(map(this.lifespan, 50, 0, 200, 50));
      c = color(c, alpha);
    }
    stroke(c);
    point(this.p.x, this.p.y);
  }
  
  void update() {
    this.lifespan -= 1.0;
    this.p = new PVector(this.p.x + this.dx, this.p.y + this.dy);
    if (this.p.x > width) this.p.x = 0;
    if (this.p.x < 0) this.p.x = width-1;
    if (this.p.y > height) this.p.y = 0;
    if (this.p.y < 0) this.p.y = height-1;
  }
  
  boolean isDead(){
    return(this.lifespan <= 0);
  }
  
  //reset all points settings
  void revive() {
    this.lifespan = random(500, 1000);
    int x0 = int(random(0, width));
    int y0 = int(random(0, height));
    this.p = new PVector(x0,y0);
    this.dx = random(-1,1);
    this.dy = random(-1,1);
  }
}

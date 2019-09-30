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


import java.util.TreeSet;

Quadtree qtree;
boolean queryMode = true; //if true show circular, if false show rectangular

public void keyPressed() {
  if (key == 'm') {
    if (queryMode) {
      queryMode = false;
    } else {
      queryMode = true;
    }
  }
}

public void setup () {
  size(1000, 400);
  background(0);
  Rectangle boundary = new Rectangle(width/2, height/2, width/2, height/2);
  qtree = new Quadtree (boundary, 8);
  int maxPoints = 10000;
  for (int i  = 0; i < maxPoints; i++) {
    float x = (width/4) +randomGaussian(width /4, width / 8);
    float y = (height/4) + randomGaussian(height / 4, height / 8);
    Point p = new Point (x, y);
    qtree.insert(p);
  }
  Rectangle range = new Rectangle(width/2, height/2, width*2, height*2);
  TreeSet<Point> points = qtree.query(range);
  println("Query range = Canvas size = "+width+", "+height);
  println("Points created = "+maxPoints);
  println("Points found = "+points.size());
}

public void draw () {
  background(0);

  qtree.show();

  stroke(0, 255, 0);
  rectMode(CENTER);

  TreeSet<Point> points = new TreeSet<Point>();

  if (queryMode) {
    //Scan points using rectangle
    Rectangle range = new Rectangle (mouseX, mouseY, 25, 25);
    rect((float)range.x, (float)range.y, (float)range.width * 2, (float)range.height * 2);
    points = qtree.query(range);
  } else {
    //Scan points using circle
    double r = 25;
    Circle range = new Circle (mouseX, mouseY, r);   
    circle((float)range.x, (float)range.y, (float)r * 2);
    points = qtree.query(range);
  }
  strokeWeight(1);
  for (Point p : points) {
    strokeWeight(4);
    point((float)p.x, (float)p.y);
  }
}

public float randomGaussian(float min, float max) {
  return min + randomGaussian() * (max - min);
}

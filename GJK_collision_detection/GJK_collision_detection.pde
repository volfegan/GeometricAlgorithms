/*
 * @author Volfegan Geist [Daniel Leite Lacerda]
 * https://github.com/volfegan
 */
//Resources
//https://www.youtube.com/watch?v=ajv46BSqcK4
//https://github.com/kroitor/gjk.c
//https://observablehq.com/@esperanc/2d-gjk-and-epa-algorithms
//https://en.wikipedia.org/wiki/Gilbert%E2%80%93Johnson%E2%80%93Keerthi_distance_algorithm

PVector[] vertices1 = {new PVector(40, 110), new PVector(90, 90), new PVector(40, 50)};
PVector[] vertices2 = {new PVector(50, 70), new PVector(120, 80), new PVector(100, 20), new PVector(70, 20)};
PVector[] vertices3 = {new PVector(640, 70), new PVector(200, 50), new PVector(170, 300)};
PVector[] vertices4 = {new PVector(400, 100)};
PVector[] vertices = new PVector[3];
PShape shape0, shape1, shape2, shape3;

//Produces a PShape from the PVector[] vertices 
void verticesToShape(PShape s, PVector[] vertices) {
  s.beginShape();
  s.noFill();
  for (int i=0; i< vertices.length; i++) {
    float x = vertices[i].x;
    float y = vertices[i].y;
    s.vertex(x, y);
  }
  s.endShape(CLOSE);
}

void setup() {
  size(1280, 720);
  translate(width/2, height/2);
  stroke(0, 255, 0);
  noFill();
  clear();
  circle(0, 0, 5);
}


void draw() {
  //translate(width/2, height/2); //to visualize the Minkowski difference between the two polygons
  clear();

  shape0 = createShape(); //follows mouse
  vertices[0] = new PVector(mouseX, mouseY, 0);
  vertices[1] = new PVector(mouseX+20, mouseY+100, 0);
  vertices[2] = new PVector(mouseX+40, mouseY+50, 0);
  verticesToShape(shape0, vertices);
   
  shape1 = createShape();
  verticesToShape(shape1, vertices1);
  shape2 = createShape();
  verticesToShape(shape2, vertices2);
  shape3 = createShape();
  verticesToShape(shape3, vertices3);
  
  
  
  shape(shape0);
  PVector c0 = calculateCentre(vertices);
  text("0", c0.x, c0.y);
  
  shape(shape1);
  PVector c1 = calculateCentre(vertices1);
  text("1", c1.x, c1.y);
  
  shape(shape2);
  PVector c2 = calculateCentre(vertices2);
  text("2", c2.x, c2.y);
  
  shape(shape3);
  PVector c3 = calculateCentre(vertices3);
  text("3", c3.x, c3.y);
  
  
  square(vertices4[0].x, vertices4[0].y, 5);
  text("4", vertices4[0].x-9, vertices4[0].y+5);
  

  print("s1 vs s2: "+gfk_detectCollision(vertices1, vertices2)+"; ");
  print("s2 vs s3: "+gfk_detectCollision(vertices2, vertices3)+"; ");
  print("s1 vs s3: "+gfk_detectCollision(vertices1, vertices3)+"; ");
  print("s1 vs s4: "+gfk_detectCollision(vertices1, vertices4)+"; ");
  println("s3 vs s4: "+gfk_detectCollision(vertices3, vertices4));
  
  print("s0 vs s1: "+gfk_detectCollision(vertices, vertices1)+"; ");
  print("s0 vs s2: "+gfk_detectCollision(vertices, vertices2)+"; ");
  print("s0 vs s3: "+gfk_detectCollision(vertices, vertices3)+"; ");
  println("s0 vs s4: "+gfk_detectCollision(vertices, vertices4)+"\n");
}

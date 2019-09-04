/**
 * This program implements a brute force method for calculating intersection points from line segments.
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
import java.util.Arrays;
import java.io.File;
import java.io.IOException;
import java.util.HashSet;


int speedReduction = 1; //1 fastest, any other bigger number slower


String[] filetxt;
String filename;
ArrayList<Line> lines = new ArrayList<Line>();
HashSet<Point> showPoints = new HashSet<Point>(); //intersectoin points
Segment[] lineSegment;
long startTime = 0;
long endTime = 0;
PrintWriter output;
boolean continueSelection = true;
int index = 0;
int otherLine = 0;
//there is no file validation, so any non-file txt selected will crash the program
//txt must contain only numbers formated as: "x0 y0 x1 y1" to create lines
//if no file is selected, 2~25 random points will be created
void fileSelected(File selection) {
  if (selection == null) {
    print("No file selected. ");
    //when cancel file selection we create some random lines
    int linesQty = int(random(2, 50));
    //int linesQty = 100;
    println(linesQty + " random segments lines created:");
    filetxt = new String[linesQty];
    //generate points method 01 (eval efficiency random segments)
    for (int i = 0; i < linesQty; i++) {
      int x0 = int(random(0, 700));
      int y0 = int(random(0, 700));
      int x1 = int(random(0, 700));
      int y1 = int(random(0, 700));
      filetxt[i] = x0+" "+y0+" "+x1+" "+y1;
    }
    /*
    //generate points method 02 (eval efficiency for any length r size segment)
     for (int i = 0; i < linesQty; i++) {
     //int r = int(random(0, 699)); //r ~ 1 to canvas size
     int r = int(random(0, 699/sqrt(sqrt(linesQty)) )); //r ~ n^(−1/4) to canvas size (sparce lines)
     //int r = int(random(0, 699/sqrt(linesQty) )); //r ~ n^(−1/2) to canvas size (very sparce lines)
     //int r = int(random(0, 699/linesQty )); //r ~ n^(−1) to canvas size (ultra sparce lines, dot like lenght)
     
     int x0 = int(random(0, 700));
     int y0 = int(random(0, 700));
     int x1 = -1;
     while (x1 < 0 || x1 > 700) {
     x1 = int(random(x0-r, x0+r));
     }
     int y1 = -1;
     while (y1 < 0 || y1 > 700) {
     y1 = int(random(y0-r, y0+r));
     }
     filetxt[i] = x0+" "+y0+" "+x1+" "+y1;
     }
     */
  } else {
    String filepath = selection.getAbsolutePath();
    filename = selection.getName();
    int pos = filename.lastIndexOf(".");
    if (pos != -1) filename = filename.substring(0, pos);
    println("File selected " + filepath);
    // load file here
    filetxt = loadStrings(filepath);
  }
}

void interrupt() { 
  while (filetxt==null) delay(200);
}

void settings() {
  selectInput("Select a txt file to process:", "fileSelected");
  interrupt(); //interrupt process until txt file is selected

  //biggest_ used to get the correct screen size
  int biggest_x = 0;
  int biggest_y = 0;

  //for testing
  //filetxt = loadStrings("LineSegmentsTEST.txt");

  println("Loading points...");
  //adding the points to display on screen
  for (String line : filetxt) {
    ArrayList<String> coordenates = new ArrayList<String>(Arrays.asList(line.split(" ")));
    int x0 = Integer.parseInt(coordenates.get(0));
    int y0 = Integer.parseInt(coordenates.get(1));
    int x1 = Integer.parseInt(coordenates.get(2));
    int y1 = Integer.parseInt(coordenates.get(3));
    println("(" + x0 + ", " + y0 + "), (" + x1 + ", " + y1 + ")");

    //create the lines from the points and put them in a list o lines
    lines.add(new Line(new PVector(x0, y0), new PVector(x1, y1)));

    if (x0 > biggest_x) biggest_x = x0;
    if (x1 > biggest_x) biggest_x = x1;
    if (y0 > biggest_y) biggest_y = y0;
    if (y1 > biggest_y) biggest_y = y1;
  }

  //extract the width and height from the txt
  width = biggest_x + 10;
  height = biggest_y + 10;
  if (width < 800) width = 800;
  if (height < 800) height = 800;

  size(width, height);
  println("width="+width +", height="+height);
}

void setup() {
  //initial canvas size is set on settings
  background(0);
  for (Line line : lines) {
    line.display();
  }

  /*
  //Brute force method for calculating intersection points
   */


  startTime = System.nanoTime();
  int n = filetxt.length; //count the number of line segments on file
  lineSegment = new Segment[n];
  println("Number of line segments = "+n);

  //creating line segments from input
  for (int i = 0; i < n; i++) {
    String line = filetxt[i];
    ArrayList<String> coordenates = new ArrayList<String>(Arrays.asList(line.split(" ")));
    int x0 = Integer.parseInt(coordenates.get(0));
    int y0 = Integer.parseInt(coordenates.get(1));
    int x1 = Integer.parseInt(coordenates.get(2));
    int y1 = Integer.parseInt(coordenates.get(3));

    Point pointA = new Point(x0, y0);
    Point pointB = new Point(x1, y1);

    lineSegment[i] = new Segment(pointA, pointB);
  }
  HashSet<Point> intersectionPoints = new HashSet<Point>(); //so that duplicates don't get added.
  int number_of_checks = 0;
  //To better measure the processing time it is better to repeat the process at least 1000 time 
  int repeatProcess = 1000;
  for (int a = 0; a < repeatProcess; a++) {

    intersectionPoints = new HashSet<Point>(); //so that duplicates don't get added.
    number_of_checks = 0;
    //brute force to find intersections with no redudant check (each element checks each other only once)
    //https://youtu.be/75Cbkoo4Gwg?t=1108
    for (int i = 0; i < n-1; i++) {
      for (int j = i + 1; j < n; j++) {
        number_of_checks++;
        if (lineSegment[i].intersect( lineSegment[j]) != null) {
          Point p_intersection = lineSegment[i].intersect( lineSegment[j]);
          intersectionPoints.add(p_intersection);
        }
      }
    }
    //end of brute force process
  }
  endTime = System.nanoTime();
  long executionTime = (endTime - startTime); // nano seconds

  //printing to file
  output = createWriter("output.txt");
  output.println("Number of line segments = "+n);
  for (Segment line : lineSegment) {
    //output.println(line.toString()); //pretty version
    output.println((int)line.a.x +" "+(int)line.a.y +" "+(int)line.b.x +" "+(int)line.b.y); //original coord
  }
  output.println();
  output.println("Number of checks = "+number_of_checks);
  output.println("Execution Time ("+repeatProcess+"x) = "+(float)executionTime/1000000 + " milliseconds");
  output.println("Line intersections = "+intersectionPoints.size());
  for (Point p : intersectionPoints) {
    output.print(p.toString()+"; ");
  }

  println("\nNumber of checks = "+number_of_checks);
  println("Execution Time ("+repeatProcess+"x) = "+(float)executionTime/1000000 + " milliseconds");
  println("Line intersections = "+intersectionPoints.size());

  output.flush();
  output.close();
  startTime = System.currentTimeMillis();
}

void draw() {
  int x0, y0, x1, y1;
  if (otherLine == 0 && index == 0) delay(3000);

  background(0);
  color green = color(0, 255, 0);
  color greenFade = color(0, 255, 0, 150);
  color cyanFade = color(0, 255, 255, 150);
  color yellowFade = color(255, 255, 0, 200);
  color redFade = color(255, 0, 0, 150);

  //show Line segments
  for (Line line : lines) {
    line.display();
  }
  //Current selected line segment
  if (continueSelection && index <= lineSegment.length-1) {
    x0 = int((float)lineSegment[index].a.x);
    y0 = int((float)lineSegment[index].a.y);
    x1 = int((float)lineSegment[index].b.x);
    y1 = int((float)lineSegment[index].b.y);
    selectLine(x0, y0, x1, y1, yellowFade, 10);
    //target shrinking effect
    if (System.currentTimeMillis() - startTime < 400) {
      selectLine(x0, y0, x1, y1, redFade, 15);
      if (System.currentTimeMillis() - startTime < 200)
        selectLine(x0, y0, x1, y1, redFade, 20);
    }
  }
  //Other line segment checking against selected line segment
  if (continueSelection && otherLine <= lineSegment.length-1 && index != otherLine) {
    x0 = int((float)lineSegment[otherLine].a.x);
    y0 = int((float)lineSegment[otherLine].a.y);
    x1 = int((float)lineSegment[otherLine].b.x);
    y1 = int((float)lineSegment[otherLine].b.y);
    selectLine(x0, y0, x1, y1, cyanFade, 10);
  }
  //find intersection
  if (continueSelection && lineSegment[otherLine].intersect( lineSegment[index]) != null) {
    Point p_intersection = lineSegment[otherLine].intersect( lineSegment[index]);
    showPoints.add(p_intersection);
  }
  //println(index+" "+otherLine+" "+continueSelection);
  //Control line intersection search on brute force
  //search indexes: [otherLine, index] created without redudant repetitions
  //last iteration
  if (otherLine >= lineSegment.length-1 && index >= lineSegment.length-2) {
    continueSelection = false;
  }
  //frameCount % speedReduction to reduce the speed of animation
  if (frameCount % speedReduction == 0) {
    if (continueSelection && otherLine < lineSegment.length-1) {
      otherLine++;
    } else {
      if (index < lineSegment.length-2) {
        startTime = System.currentTimeMillis();
        index++;
        otherLine = index+1;
      }
    }
  }
  //Rectangule crosshairs
  stroke(green);
  strokeWeight(0);
  noFill();
  rectMode(CENTER);
  for (Point p : showPoints) {
    rect((float)p.x, (float) p.y, 20, 20, 1);
  }
  //Intersection points
  stroke(green);
  strokeWeight(5);
  for (Point p : showPoints) {
    point((float)p.x, (float)p.y);
  }
}

//creates a box around a segment line
void selectLine(int x0_, int y0_, int x1_, int y1_, color color_, int box_size) {
  int x1, y1, x2, y2, x3, y3, x4, y4;
  int offsetX, offsetY;
  stroke(color_);
  double angle = Math.toDegrees(Math.atan2(y1_-y0_, x1_-x0_));
  if (angle > 90) angle -= 180;
  if (angle < -45) angle += 180;
  if (angle < 45) {
    offsetX = 0;
    offsetY = box_size;
    x1 = x0_ - offsetX;
    y1 = y0_ + offsetY;

    x2 = x0_ - offsetX;
    y2 = y0_ - offsetY;

    x3 = x1_ + offsetX;
    y3 = y1_ - offsetY;

    x4 = x1_ + offsetX;
    y4 = y1_ + offsetY;
  } else {
    offsetX = box_size;
    offsetY = 0;
    x1 = x0_ + offsetX;
    y1 = y0_ + offsetY;

    x2 = x0_ - offsetX;
    y2 = y0_ - offsetY;

    x3 = x1_ - offsetX;
    y3 = y1_ - offsetY;

    x4 = x1_ + offsetX;
    y4 = y1_ + offsetY;
  }
  quad(x1, y1, x2, y2, x3, y3, x4, y4);
}

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

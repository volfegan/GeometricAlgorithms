/**
 * This program implements the Plane Sweep for line segment intersection
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
import java.util.Arrays;
import java.io.File;
import java.io.IOException;
import java.util.TreeSet;
import java.util.Iterator;

int speedReduction = 2; //1 fastest, any other bigger number slower

String[] filetxt;
String filename;
ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<Point> showPoints = new ArrayList <Point>();
ArrayList<Point> intersectionPoints = new ArrayList<Point>();
Segment[] lineSegments;
long startTime = 0;
long endTime = 0;
PrintWriter output;
int scanLine = 0;
//there is no file validation, so any non-img selected will crash the program
void fileSelected(File selection) {
  if (selection == null) {
    print("No file selected. ");
    //when cancel file selection we create some random lines
    int linesQty = int(random(2, 50));
    //int linesQty = 100;
    println(linesQty + " random segments lines created:");
    int screenSize = 900;
    filetxt = new String[linesQty];
    //generate points method 01 (eval efficiency random segments)
    for (int i = 0; i < linesQty; i++) {
      int x0 = int(random(0, screenSize));
      int y0 = int(random(0, screenSize));
      int x1 = int(random(0, screenSize));
      int y1 = int(random(0, screenSize));
      filetxt[i] = x0+" "+y0+" "+x1+" "+y1;
    }
    /*
    //generate points method 02 (eval efficiency for any length r size segment)
     for (int i = 0; i < linesQty; i++) {
     //int r = int(random(0, screenSize-10)); //r ~ 1 to canvas size
     //int r = int(random(0, (screenSize-10)/sqrt(sqrt(linesQty)) )); //r ~ n^(−1/4) to canvas size (sparce lines)
     //int r = int(random(0, (screenSize-10)/sqrt(linesQty) )); //r ~ n^(−1/2) to canvas size (very sparce lines)
     int r = int(random(0, (screenSize-10)/linesQty )); //r ~ n^(−1) to canvas size (ultra sparce lines, dot like lenght)
     
     int x0 = int(random(0, screenSize));
     int y0 = int(random(0, screenSize));
     int x1 = -1;
     while (x1 < 0 || x1 > screenSize) {
     x1 = int(random(x0-r, x0+r));
     }
     int y1 = -1;
     while (y1 < 0 || y1 > screenSize) {
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
  interrupt(); //interrupt process until txt is selected

  int biggest_x = 0;
  int biggest_y = 0;

  //for testing
  //filetxt = loadStrings("LineSegmentsTEST.txt");

  println("Loading points...");
  for (String line : filetxt) {
    println(line);
    ArrayList<String> coordenates = new ArrayList<String>(Arrays.asList(line.split(" ")));
    int x0 = Integer.parseInt(coordenates.get(0));
    int y0 = Integer.parseInt(coordenates.get(1));
    int x1 = Integer.parseInt(coordenates.get(2));
    int y1 = Integer.parseInt(coordenates.get(3));

    //create the lines from the points and put them in a list o lines
    lines.add(new Line(new PVector(x0, y0), new PVector(x1, y1)));

    if (x0 > biggest_x) biggest_x = x0;
    if (x1 > biggest_x) biggest_x = x1;
    if (y0 > biggest_y) biggest_y = y0;
    if (y1 > biggest_y) biggest_y = y1;
  }

  //extract the width and height from the txt
  width = biggest_x + 50;
  height = biggest_y + 50;
  if (width <= 900) width = 900;
  if (height <= 900) height = 900;

  size(width, height);
}

void setup() {
  //initial canvas size is set on settings
  background(0);
  for (Line line : lines) {
    line.display();
  }



  /*
  //Plane Sweep for line segment intersection
   */


  startTime = System.nanoTime();
  int n = filetxt.length; //count the number of line segments on file
  lineSegments = new Segment[n];
  println("Number of line segments = "+n);

  //creating line segments from input file
  for (int i = 0; i < n; i++) {
    String line = filetxt[i];
    ArrayList<String> coordenates = new ArrayList<String>(Arrays.asList(line.split(" ")));
    int x0 = Integer.parseInt(coordenates.get(0));
    int y0 = Integer.parseInt(coordenates.get(1));
    int x1 = Integer.parseInt(coordenates.get(2));
    int y1 = Integer.parseInt(coordenates.get(3));

    Point pointA = new Point(x0, y0);
    Point pointB = new Point(x1, y1);

    lineSegments[i] = new Segment(pointA, pointB);
  }

  IntersectionFinder planeSweep = new IntersectionFinder(lineSegments);
  intersectionPoints = planeSweep.find_intersections();
  int event_counter = planeSweep.get_event_qty();
  //To better measure the processing time it is better to repeat the process at least 1000 time 
  int repeatProcess = 1000; //we already did one
  for (int a = 0; a < repeatProcess -1; a++) {
    
    for (Segment s : lineSegments) {
      s.calculate_value(s.startPoint().get_x()); //reset the 'value' field to original status
    }
    IntersectionFinder test = new IntersectionFinder(lineSegments);
    test.find_intersections();
  }
  //end of Plane Sweep for line segment intersection process
  endTime = System.nanoTime();
  long executionTime = (endTime - startTime); // nano seconds

  //printing to file
  output = createWriter("output.txt");
  output.println("Number of line segments = "+n);
  for (Segment line : lineSegments) {
    //output.println(line.toString()); //pretty version
    output.println((int)line.get_a().x +" "+(int)line.get_a().y +" "+(int)line.get_b().x +" "+(int)line.get_b().y); //original coord
  }
  output.println();
  output.println("Number of events = "+event_counter);
  output.println("Execution Time ("+repeatProcess+"x) = "+(float)executionTime/1000000 + " milliseconds");
  output.println("Line intersections = "+intersectionPoints.size());
  for (Point p : intersectionPoints) {
    output.print(p.toString()+"; ");
  }

  println("\nNumber of events = "+event_counter);
  println("Execution Time ("+repeatProcess+"x) = "+(float)executionTime/1000000 + " milliseconds");
  println("Line intersections = "+intersectionPoints.size());

  output.flush();
  output.close();
}

void draw() {
  background(0);
  color green = color(0, 255, 0);
  color greenFade = color(0, 255, 0, 100);

  if (scanLine == 0) delay(3000);
  
  
  //check if relevant points are in the scanLine and add to showPoints
  //doing backwards to avoid try to access deleted content
  for (int i = intersectionPoints.size() -1; i >= 0; i--) {
    Point p = intersectionPoints.get(i);
    if (p.x <= scanLine) {
      showPoints.add(p);
      intersectionPoints.remove(i);
    }
  }

  //Line segments made of a->b points
  for (Line line : lines) {
    //show start points when scanLine pass by
    if (line.a.x == scanLine) {
      line.lifespan_a = millis();
      line.show_a = true;
    }
    //show end points when scanLine pass by
    if (line.b.x == scanLine) {
      line.lifespan_b = millis();
      line.show_b = true;
    }
    //
    if (line.a_isDead() ) line.show_a = false;
    if (line.b_isDead() ) line.show_b = false;
    line.display();
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
  for (Point p : showPoints) {
    stroke(green);
    strokeWeight(7);
    point((float)p.x, (float)p.y);
  }

  //scanLine
  stroke(greenFade);
  strokeWeight(7);
  line(scanLine, 0, scanLine, height);
  if (frameCount % speedReduction == 0) scanLine++;
  if (scanLine > width && is_endpoints_still_activated() == false) noLoop();
}

boolean is_endpoints_still_activated() {
  for (Line line : lines) {
    if (!line.a_isDead() && line.show_a == true) return true;
  }
  for (Line line : lines) {
    if (!line.b_isDead() && line.show_b == true) return true;
  }
  return false;
}

/**
 * Used just to display the lines on processing (not used in the calculations)
 */
class Line {

  PVector a, b;
  int lifespan_a, lifespan_b;
  boolean show_a, show_b;
  //construct the segment lines with lower x (on left) as start points 'a'
  Line(PVector a, PVector b) {
    if (a.x < b.x) {
      this.a = a;
      this.b = b;
    }
    if (b.x < a.x) {
      this.a = b;
      this.b = a;
    }
    if (a.x == b.x) {
      if (a.y < b.y) {
        this.a = a;
        this.b = b;
      } else {
        this.a = b;
        this.b = a;
      }
      this.lifespan_a = 0;
      this.lifespan_b = 0;
      this.show_a = false;
      this.show_b = false;
    }
  }
  boolean a_isDead() {
    return(this.lifespan_a  + 2000 <= millis());
  }
  boolean b_isDead() {
    return(this.lifespan_b  + 1000 <= millis());
  }

  void display() {
    //display line
    color c = color(a.x % 255, 255-a.y % 255, b.y % 255);
    strokeWeight(2);
    stroke(c);
    line(this.a.x, this.a.y, this.b.x, this.b.y);

    //display point a
    if (this.show_a) {
      color yellowFade = color(255, 255, 0, 150);
      strokeWeight(7);
      stroke(yellowFade);
      point((float)this.a.x, (float)this.a.y);
      //Rectangule crosshairs on start points
      strokeWeight(0);
      noFill();
      rectMode(CENTER);
      rect((float)this.a.x, (float)this.a.y, 25, 25, 2);
    }
    //display point b
    if (this.show_b) {
      color cyanFade = color(0, 255, 255, 150);
      strokeWeight(7);
      stroke(cyanFade);
      point((float)this.b.x, (float)this.b.y);
      //Rectangule crosshairs on end points
      strokeWeight(0);
      noFill();
      rectMode(CENTER);
      rect((float)this.b.x, (float)this.b.y, 25, 25, 2);
    }
  }
}

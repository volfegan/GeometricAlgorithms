/*Marching Squares Metaballs Interpolation with filling colours gradient
 * @author Volfegan [Daniel L Lacerda]
 * 
 */
//References:
//https://en.wikipedia.org/wiki/Marching_squares
//http://jamie-wong.com/2014/08/19/metaballs-and-marching-squares/
//Basic implementations of colour metaballs and meta-diamonds
//https://gist.github.com/volfegan/3a1fd4e9b4a42bdcc3a3ba3842ca449a

//The Coding Train / Daniel Shiffman
//https://youtu.be/0ZONMNUKTfU
//https://github.com/CodingTrain/website/tree/main/challenges/coding-in-the-cabana/005_marching_squares/Processing_metaballs_interpolation/

//Looping static pseudo-Metaball Plasma Field
//https://www.dwitter.net/d/5321
//https://gist.github.com/volfegan/701ce29a7244831b61e86b4092c9c9ff

Blob[] blobs = new Blob[30];
float[][] field;
int rez = 15;
int cols, rows;

int showResolutionGrid = 0; //0. no grid, 1. grid, 2. grid outside the blobs, 3. grid inside the blobs
boolean showContourLines = true;
boolean showColours = true;
boolean fullLights = false; //no marching squares boundaries for the field values/colour = slow
int colourMode = 0; //0. Yellow, 1. Liquid Diamond, 2. Cyan-Blue, 3. Fast Liquid Diamond

void keyPressed() {
  if (key == 'G' || key == 'g') {
    showResolutionGrid++;
    showResolutionGrid%=4;
  }
  if (key == 'M' || key == 'm') {
    colourMode++;
    colourMode%=4;
  }
  if (key == 'F' || key == 'f') {
    if (fullLights) fullLights = false;
    else fullLights = true;
  }
  if (key == 'C' || key == 'c') {
    if (showColours) showColours = false;
    else showColours = true;
  }
  if (key == 'L' || key == 'l') {
    if (showContourLines) showContourLines = false;
    else showContourLines = true;
  }
  //adjust the resolution space of the field +/-
  if (key == '+') {
    if (rez < 50) rez ++;
    initMetaballsField();
    println("Resolution grid: "+rez);
  }
  if (key == '-') {
    if (rez > 2) rez --;
    initMetaballsField();
    println("Resolution grid: "+rez);
  }
}
void setup() {
  size(1280, 720, P2D);
  strokeWeight(1);
  println("Resolution grid: "+rez);

  cols = 2 + width / rez;
  rows = 2 + height / rez;
  field = new float[cols][rows];
  for (int i = 0; i < blobs.length; i++) {
    //4 star-diamond, the rest is regular metaballs
    blobs[i] = new Blob(i>3 ? 0:1);//0 for circle | 1 for star-diamond
  }
}

void draw() {
  background(0);

  //Generate the metaball field values 
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float sum = 0;
      float x = i * rez;
      float y = j * rez;
      for (Blob b : blobs) {
        if (b.shape == 0) sum += b.r*b.r / ((x-b.x)*(x-b.x) + (y-b.y)*(y-b.y));//Metaball
        if (b.shape == 1)sum += b.r / (abs(x-b.x) + abs(y-b.y));//Meta-Diamond
      }
      field[i][j] = sum;
    }
  }

  //Marching Squares isolines
  for (int i = 0; i < cols-1; i++) {
    for (int j = 0; j < rows-1; j++) {
      float x = i * rez;
      float y = j * rez;

      float threshold = 1;
      int c1 = field[i][j]  < threshold ? 0 : 1;
      int c2 = field[i+1][j]  < threshold ? 0 : 1;
      int c3 = field[i+1][j+1]  < threshold ? 0 : 1;
      int c4 = field[i][j+1]  < threshold ? 0 : 1;
      int state = getState(c1, c2, c3, c4);

      //colour the inside of the blobs with a rectangular vertex with gradient colours
      if (state == 15 || fullLights) {
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);
        endShape();
      }

      //interpolation
      /*The dot . is the field values
       .___a___.
       |       |
       d       b
       |       |
       .___c___.
       */
      float a_val = field[i][j];
      float b_val = field[i+1][j];
      float c_val = field[i+1][j+1];
      float d_val = field[i][j+1];      

      PVector a = new PVector();
      float amt = (1 - a_val) / (b_val - a_val);
      a.x = lerp(x, x + rez, amt);
      a.y = y;

      PVector b = new PVector();
      amt = (1 - b_val) / (c_val - b_val);
      b.x = x + rez;
      b.y = lerp(y, y + rez, amt);

      PVector c = new PVector();
      amt = (1 - d_val) / (c_val - d_val);
      c.x = lerp(x, x + rez, amt);
      c.y = y + rez;

      PVector d = new PVector();
      amt = (1 - a_val) / (d_val - a_val);
      d.x = x;
      d.y = lerp(y, y + rez, amt);

      //Marching squares rule table https://en.wikipedia.org/wiki/File:Marching_squares_algorithm.svg
      switch (state) {
      case 1:
        //bottom left triangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(d.x, d.y);

        fill(getColour(i+1, j+1));
        vertex(c.x, c.y);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);
        endShape();

        contourLine(c, d);
        break;
      case 2:
        //bottom right triangle
        noStroke();
        beginShape();
        fill(getColour(i+1, j));
        vertex(b.x, b.y);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(c.x, c.y);
        endShape();

        contourLine(b, c);
        break;
      case 3:
        //retangular bottom half
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(d.x, d.y);

        fill(getColour(i+1, j));
        vertex(b.x, b.y);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);
        endShape();

        contourLine(b, d);
        break;
      case 4:
        //top right triangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(a.x, a.y);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i, j+1));
        vertex(b.x, b.y);
        endShape();

        contourLine(a, b);
        break;
      case 5:
        //bottom-left to top-right middle hexagon slice
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(a.x, a.y);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i+1, j));
        vertex(b.x, b.y);

        fill(getColour(i, j+1));
        vertex(c.x, c.y);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);

        fill(getColour(i, j));
        vertex(d.x, d.y);
        endShape();

        contourLine(a, d);
        contourLine(b, c);
        break;
      case 6:
        //retangular left side half
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(a.x, a.y);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(c.x, c.y);
        endShape();

        contourLine(a, c);
        break;
      case 7:
        //Pentagonal shape from subtracted top-left triangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(a.x, a.y);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);

        fill(getColour(i, j));
        vertex(d.x, d.y);
        endShape();

        contourLine(a, d);
        break;
      case 8:
        //top-left triangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex(a.x, a.y);

        fill(getColour(i, j+1));
        vertex(d.x, d.y);
        endShape();

        contourLine(a, d);
        break;
      case 9:
        //left side rectangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex(a.x, a.y);

        fill(getColour(i+1, j+1));
        vertex(c.x, c.y);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);
        endShape();

        contourLine(a, c);
        break;
      case 10:
        //top-left to bottom-right middle hexagon slice
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex(a.x, a.y);

        fill(getColour(i+1, j));
        vertex(b.x, b.y);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(c.x, c.y);

        fill(getColour(i, j+1));
        vertex(d.x, d.y);
        endShape();

        contourLine(a, b);
        contourLine(c, d);
        break;
      case 11:
        //Pentagonal shape from subtracted top-right triangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex(a.x, a.y);

        fill(getColour(i+1, j));
        vertex(b.x, b.y);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);
        endShape();

        contourLine(a, b);
        break;
      case 12:
        //Top half rectangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i+1, j+1));
        vertex(b.x, b.y);

        fill(getColour(i, j+1));
        vertex(d.x, d.y);
        endShape();

        contourLine(b, d);
        break;
      case 13:
        //Pentagonal shape from subtracted bottom-right triangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i+1, j+1));
        vertex(b.x, b.y);

        fill(getColour(i+1, j+1));
        vertex(c.x, c.y);

        fill(getColour(i, j+1));
        vertex(i*rez, (j+1)*rez);
        endShape();

        contourLine(b, c);
        break;
      case 14:
        //Pentagonal shape from subtracted bottom-left triangle
        noStroke();
        beginShape();
        fill(getColour(i, j));
        vertex(i*rez, j*rez);

        fill(getColour(i+1, j));
        vertex((i+1)*rez, j*rez);

        fill(getColour(i+1, j+1));
        vertex((i+1)*rez, (j+1)*rez);

        fill(getColour(i, j+1));
        vertex(c.x, c.y);

        fill(getColour(i, j+1));
        vertex(d.x, d.y);
        endShape();

        contourLine(c, d);
        break;
      }
      //show resolution grid inside or outside the blobs
      if ((state == 0 && showResolutionGrid==2) || (state == 15 && showResolutionGrid==3)) {
        stroke(200, 100);
        noFill();
        rect(i*rez, j*rez, rez, rez);
      }
    }
  }
  //full resolution grid on screen
  if (showResolutionGrid==1) {
    stroke(200, 100);
    for (int i = 0; i < cols; i++) {
      line(i*rez, 0, i*rez, height);
    }
    for (int j = 0; j < rows; j++) {
      line(0, j*rez, width, j*rez);
    }
  }
  for (Blob b : blobs) {
    b.update();
    b.show();
  }
}

//Get the decimal value for the 4-bit binary number abcd
int getState(int a, int b, int c, int d) {
  return a * 8 + b * 4  + c * 2 + d * 1;
}

//generate the colour for each field point position
color getColour(int x, int y) {
  color c=color(0, 0);
  float value = field[x][y]*255;
  if (showColours==false || showResolutionGrid>=2) {
    return c;
  }
  if (colourMode==0) {
    //Yellow core
    c = color(value*.75, value*.6, 0);
  } else if (colourMode==1) {
    //Liquid Diamond from static pseudo-Metaball Plasma Field
    c = color(A(x, y, value/255+frameCount*.02), 
      A(x, y, value/255+frameCount*.02+.2), 
      A(x, y, value/255+frameCount*.02+.4));
  } else if (colourMode==2) {
    //Cyan-blue core
    c = color(0, value*.65, value*.85);
  } else if (colourMode==3) {
    //Fast Liquid Diamond from static pseudo-Metaball Plasma Field
    c = color(A(x, y, value/(100+75*sin(frameCount*.02))), 
      A(x, y, value/(100+75*sin(frameCount*.02))+.2), 
      A(x, y, value/(100+75*sin(frameCount*.02))+.4));
  }
  return c;
}
//Produces a metaball like Plasma field RGB colour mapping
float A(float x, float y, float t) {
  return (sin(x/9+t)*sin(y/7)+sin(y/9+t)*sin(x/7-t))*255;
}

void contourLine(PVector v1, PVector v2) {
  if (showContourLines || showColours==false) {
    stroke(50);
    line(v1.x, v1.y, v2.x, v2.y);
  }
}
//Reset new resolution size changes
void initMetaballsField() {
  cols = 2 + width / rez;
  rows = 2 + height / rez;
  field = new float[cols][rows];
  //Generate the metaball field values 
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float sum = 0;
      float x = i * rez;
      float y = j * rez;
      for (Blob b : blobs) {
        sum += b.r*b.r / ((x-b.x)*(x-b.x) + (y-b.y)*(y-b.y));
      }
      field[i][j] = sum;
    }
  }
}

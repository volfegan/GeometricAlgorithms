/*
 * @author Volfegan Geist [Daniel Leite Lacerda]
 * https://github.com/volfegan
 */
/*
 //Resources:
 //https://www.youtube.com/watch?v=ajv46BSqcK4
 //https://github.com/kroitor/gjk.c
 //https://observablehq.com/@esperanc/2d-gjk-and-epa-algorithms
 //https://en.wikipedia.org/wiki/Gilbert%E2%80%93Johnson%E2%80%93Keerthi_distance_algorithm
 */

/*
 * Calculates the magnitude (length) of the vector, squared.
 * @param PVector v
 * @return float (v.x * v.x + v.y * v.y + v.z * v.z)
 */
float lengthSquared(PVector v) {
  return v.magSq(); //I don't like the method name "magSq()"
}
/*
//lengthSquared test
 println(lengthSquared(new PVector(1,0,0)));//1
 println(lengthSquared(new PVector(2,0,0)));//4
 println(lengthSquared(new PVector(1,2,0)));//5
 println(lengthSquared(new PVector(1,1,2)));//6
 */


/*
 * Triple product expansion to calculate perpendicular normal vectors
 * for search directions pointing towards the Origin in Minkowski space
 * @param PVector a, b, c
 * @return PVector A x (B x C)
 */
PVector tripleProduct(PVector a, PVector b, PVector c) {
  return a.cross(b.cross(c));
}
/*
//tripleProduct test
 println(tripleProduct(new PVector(1,0,0), new PVector(0,1,0), new PVector(1,1,1))); //= [0,1,0]
 println(tripleProduct(new PVector(1,1,-1), new PVector(0,1,0), new PVector(1,1,1))); //= [-1,0,-1]
 println(tripleProduct(new PVector(1,0,-1), new PVector(0,-1,0), new PVector(1,1,1))); //= [0,0,0]
 */

/*
 * Compute the average center (roughly) for initial direction of simplex search in GJK
 * @param PVector[] vertices[(x0,y0),(x1,y1),...]
 * @return PVector centre
 */
PVector calculateCentre(PVector[] vertices) {
  int gonSize = vertices.length; //Number of edges in the polygon
  PVector centre = new PVector();
  for (int i = 0; i < gonSize; i++) {
    float x = vertices[i].x;
    float y = vertices[i].y;
    centre.x += x;
    centre.y += y;
  }
  centre.x /= gonSize;
  centre.y /= gonSize;
  return centre;
}
/*
//test 
 PVector[] vertices = {new PVector(0,3,0), new PVector(0,0,0), new PVector(3,3,0)};
 println(calculateCentre(vertices)); //= [1,2,0]
 PVector[] vertices = {new PVector(-1,1,0), new PVector(1,1,0), new PVector(-1,-1,0), new PVector(1,-1,0)};
 println(calculateCentre(vertices)); //= [0,0,0]
 */


/*
 * returns the Minkowski difference between the two polygons
 * @param PVector[] vertices1[(x0,y0),(x1,y1),...], vertices2[(x0,y0),(x1,y1),...]
 * @return PVector[]
 */
PVector[] minkDiff(PVector[] vertices1, PVector[] vertices2) {
  PVector[] minkDiffResult = new PVector[vertices1.length * vertices2.length];
  int index = 0;
  for (PVector P1 : vertices1) {
    for (PVector P2 : vertices2) {
      minkDiffResult[index] = PVector.sub(P1, P2);
      index++;
    }
  }
  //show Minkowski difference points
  stroke(255);
  //if the canvas origin is not at the centre: translate(width/2, height/2);
  for (int i=0; i< minkDiffResult.length; i++) {
    float x = minkDiffResult[i].x;
    float y = minkDiffResult[i].y;
    square(x, y, 5);
  }
  return minkDiffResult;
}


/*
 * returns the point from the shape which has the highest dot product with vector d.
 * @param PVector[] vertices[(x0,y0),(x1,y1),...], direction d
 * @return PVector
 */
PVector furthestPoint(PVector[] vertices, PVector d) {
  float x, y, product, maxProduct;
  int gonSize = vertices.length; //Number of edges in the polygon
  x = vertices[0].x;
  y = vertices[0].y;
  //1st point
  PVector vertice = new PVector(x, y);
  maxProduct = d.dot(vertice);

  int index = 0;
  for (int i = 1; i < gonSize; i++) {
    x = vertices[i].x;
    y = vertices[i].y;
    vertice = new PVector(x, y);
    product = d.dot(vertice);

    if (product >= maxProduct) {
      maxProduct = product;
      index = i;
    }
  }
  return vertices[index];
}
/*
//test 
PVector[] vertices = {new PVector(0,3,0), new PVector(0,0,0), new PVector(3,3,0)};
 println(vertices);
 println(furthestPoint(vertices, new PVector(1,0,0))); //= [3,3,0]
 println(furthestPoint(vertices, new PVector(0,1,0))); //= [0,3,0] or [3,3,0]
 println(furthestPoint(vertices, new PVector(2,1,0))); //= [3,3,0]
 */


/*
 * returns the support point of the Minkowski difference between the two polygons on direction d & -d
 * @param PVector[] vertices1[(x0,y0),(x1,y1),...], vertices2[(x0,y0),(x1,y1),...], direction d
 * @return PVector
 */
PVector support(PVector[] vertices1, PVector[] vertices2, PVector d) {
  PVector P1 = furthestPoint(vertices1, d);
  PVector P2 = furthestPoint(vertices2, PVector.mult(d, -1));
  return PVector.sub(P1, P2);
}
/*
//test 
And I deleted by mistake this test. It works. Trust me!
*/

/*
 * The GJK collision detection algorithm
 * @param PVector[] vertices1[(x0,y0),(x1,y1),...], vertices2[(x0,y0),(x1,y1),...]
 * @return boolean
 */
boolean gfk_detectCollision(PVector[] vertices1, PVector[] vertices2) {
  double MIN_CENTROID_SEPARATION_SQUARED = 1.0e-9f;
  PVector a, b, c; //Points of the simplex
  PVector d, aO, ab, ac; //Directions
  //simplex that contains the origin within the hull of the Minkowski difference
  ArrayList<PVector> simplex = new ArrayList<PVector>();

  // initial direction from the center of 1st shape to the center of 2nd shape
  PVector centre1 = calculateCentre(vertices1);
  PVector centre2 = calculateCentre(vertices2);
  d = PVector.sub(centre2, centre1);
  if (lengthSquared(d) < MIN_CENTROID_SEPARATION_SQUARED ) {
    //println("MIN_CENTROID_SEPARATION_SQUARED");
    return true;
  }
  d.normalize();

  //First point
  a = support(vertices1, vertices2, d);
  simplex.add(a);

  d = PVector.mult(a, -1);//Origin - point, a vector pointing to (0,0,0)
  d.normalize();

  int counter=0;
  while (true) {
    counter++;
    a = support(vertices1, vertices2, d);
    simplex.add(a);
    if (a.dot(d) < 0) {
      //println("No colision (iteration="+counter+")");

      return false; // no collision
    }

    //simplex line case
    if (simplex.size() == 2) {
      a = simplex.get(0);
      b = simplex.get(1);

      ab = PVector.sub(b, a);
      aO = PVector.mult(a, -1); //Origin - A, a vector pointing to (0,0,0)
      PVector ab_perpendicular = tripleProduct(ab, aO, ab);
      d = ab_perpendicular;
      d.normalize();
      continue;
    }
    //simplex triangle case
    if (simplex.size() == 3) {
      a = simplex.get(0);
      b = simplex.get(1);
      c = simplex.get(2);

      ab = PVector.sub(b, a);
      ac = PVector.sub(c, a);
      aO = PVector.mult(a, -1); //Origin - A, a vector pointing to (0,0,0)

      PVector ab_perpendicular = tripleProduct(ac, ab, ab);
      PVector ac_perpendicular = tripleProduct(ab, ac, ac);


      if (ab_perpendicular.dot(aO) > 0) {
        //Region AB
        simplex.remove(c); //remove point C
        d = ab_perpendicular;
        d.normalize();
      } else if (ac_perpendicular.dot(aO) > 0) {
        //Region AC
        simplex.remove(b); //remove point B
        d = ac_perpendicular;
        d.normalize();
      } else {
        //println("Colision (iteration="+counter+")");
        //println("simplex: a="+simplex.get(0)+"; b="+simplex.get(1)+"; c="+simplex.get(2));
        return true;
      }
    }
  }
}

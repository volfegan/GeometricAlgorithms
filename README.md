# Geometric Algorithms
Geometric Algorithms implemented in Java and Processing v3. Algorithms details can be found at: [Computational Geometry - Algorithms and Applications, 3rd Ed](https://people.inf.elte.hu/fekete/algoritmusok_msc/terinfo_geom/konyvek/Computational%20Geometry%20-%20Algorithms%20and%20Applications,%203rd%20Ed.pdf).


#### Brute Force Plane sweep
Initial implementation  of an efficient Plane sweep Line Segment Intersection. This visualization program shows how the brute force works its way in a 2D loop to find all the intersections from some given points that form lines. Basically, every line checks against the others for some point intersection. The text file on the data directory contains the points that form lines following this format separated only by space. Example:

| *x0*  |  *y0* |  *x1* |  *y1* |
| ------|------ | ------|------ |
|  91   |  179  |  760  |  353  |
|  874  |  890  |  648  |  114  |
|  687  |  715  |  939  |  747  |

(The x0, y0, x1, y1 line doesn't exist in the file, just the numbers). 

If you run the program the user can either choose the txt file contenting the points or just cancel the file choosing to automatically generate a random number of points (2~25). By running the visualization it will produce a file "output.txt" with the number of points, intersections, processing time and other relevant data. The algorithm itself is found on processing setup() function and it is general enough to be use in any Java aplication (although very inefficient). The visualization just shows how the algorithm works in a slow, comprehensible manner. See below the visualization:

[![Visualization of Line Intersections brute force search algorithm](https://i.ytimg.com/vi/pyxHgQsKN2g/hqdefault.jpg?sqp=-oaymwEZCNACELwBSFXyq4qpAwsIARUAAIhCGAFwAQ==&rs=AOn4CLAr2lVJdZ0f4sjrXPPIDrYiJos_Hg)](https://www.youtube.com/watch?v=pyxHgQsKN2g)

\- \- \-

\[ all code available under MIT License - feel free to use. \]

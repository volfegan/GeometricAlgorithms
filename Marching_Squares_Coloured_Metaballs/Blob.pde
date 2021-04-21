

class Blob {
  float x, y;
  float vx, vy;
  float r;
  int shape;//0 for circle | 1 for star-diamond
  PGraphics blob_img;

  Blob(int number) {
    this.shape = number%2; //any number will be either 0 or 1
    this.r = random(20, 50);
    this.x = random(this.r, width-this.r);
    this.y = random(this.r, height-this.r);
    this.vx = random(-2, 2);
    this.vy = random(-2, 2);

    //draw a spheric blob
    if (this.shape == 0) {
      int size = (int)this.r*2;
      this.blob_img = createGraphics(size, size);
      this.blob_img.beginDraw();
      this.blob_img.clear();
      this.blob_img.background(0, 0);
      this.blob_img.loadPixels();
      this.blob_img.noStroke();
      for (int i=size-1; i>0; i--) 
        for (int j=size-1; j>0; j--) {
          float d = dist(size/2, size/2, i, j);
          float alpha = map(d, 0, this.r, 60, 0);
          int index = i + j * size;
          this.blob_img.pixels[index] = color(255, alpha);
        }
      this.blob_img.updatePixels();
      this.blob_img.endDraw();
    }
    //draw star-diamond blob
    if (this.shape == 1) {
      int size = (int)this.r*2;
      this.blob_img = createGraphics(size, size);
      this.blob_img.beginDraw();
      this.blob_img.clear();
      this.blob_img.background(0, 0);
      this.blob_img.loadPixels();
      this.blob_img.noStroke();
      for (int i=size-1; i>0; i--) 
        for (int j=size-1; j>0; j--) {
          float d = (size/2)*(size/2)/(1+abs(size/2 - i)+abs(size/2 - j));
          float alpha = map(d, size, 0, 20, -10);
          int index = i + j * size;
          this.blob_img.pixels[index] = color(255, alpha);
        }
      this.blob_img.updatePixels();
      this.blob_img.endDraw();
    }
  }

  void show() {
    image(this.blob_img, this.x-this.r, this.y-this.r, this.r*2, this.r*2);
  }

  void update() {
    this.x += this.vx;
    this.y += this.vy;
    if (this.x > width-this.r  || this.x < this.r) {
      this.vx *= -1;
    }
    if (this.y > height-this.r  || this.y < this.r) {
      this.vy *= -1;
    }
  }
}

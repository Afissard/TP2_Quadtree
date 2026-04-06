// Particle class
class Particle {
  float x, y;
  
  Particle(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display(color col) {
    fill(col);
    noStroke();
    ellipse(x, y, 5, 5);
  }
}
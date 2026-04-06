// Particle class
class Particle {
  float x, y;
  color col;
  
  Particle(float x, float y, color col) {
    this.x = x;
    this.y = y;
    this.col = col;
  }

  void display() {
    fill(col);
    noStroke();
    ellipse(x, y, 5, 5);
  }
}

// List of Color for the particles
color[] colors = {
    color(255, 0, 0),   // Red
    color(0, 255, 0),   // Green
    color(0, 0, 255),   // Blue
    color(255, 255, 0), // Yellow
    color(255, 0, 255), // Magenta
    color(0, 255, 255)  // Cyan
};

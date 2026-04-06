class Particle {
  float x, y;
  color col; 
  float vx, vy;

  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    this.col = color(255); 
    
    this.vx = random(-2, 2);
    this.vy = random(-2, 2);
  }

  void update(float w, float h) {
    x += vx;
    y += vy;
    
    if (x <= 0 || x >= w) {
      vx *= -1;
      x = constrain(x, 0, w);
    }
    if (y <= 0 || y >= h) {
      vy *= -1;
      y = constrain(y, 0, h);
    }
  }

  void display() {
    if (this == selected) {
      stroke(255);
      strokeWeight(2);
    } else {
      noStroke();
    }

    fill(col);
    ellipse(x, y, 6, 6);
  }
}
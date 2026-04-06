class Particle {
  float x, y;
  Node owner;
  color col; 

  float vx, vy;

  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    this.col = color(255); 
    
    this.vx = random(-2, 2);
    this.vy = random(-2, 2);
  }

  void update(float worldW, float worldH) {
    x += vx;
    y += vy;
    
    if (x <= 0 || x >= worldW) {
      vx *= -1;
      x = constrain(x, 0.001f, worldW - 0.001f);
    }
    if (y <= 0 || y >= worldH) {
      vy *= -1;
      y = constrain(y, 0.001f, worldH - 0.001f);
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
class Particle {
  float x, y;
  color col; // AJOUT

  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    this.col = color(255); // valeur par défaut
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

/**
 * Represents a particle moving inside the simulation world.
 * Each particle stores its position, velocity, display color,
 * and a reference to the quadtree node that currently owns it.
 */
class Particle {
  float x, y;      // Current position
  Node owner;      // Quadtree node that contains this particle
  color col;       // Display color

  float vx, vy;    // Current velocity

  /**
   * Creates a particle at the given position with a random velocity.
   *
   * @param x initial x position
   * @param y initial y position
   */
  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    this.col = color(255);

    this.vx = random(-2, 2);
    this.vy = random(-2, 2);
  }

  /**
   * Updates the particle position and bounces it off the world bounds.
   *
   * @param worldW world width
   * @param worldH world height
   */
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

  /** Draws the particle, highlighting it when selected. */
  void display() {
    if (this == selected) {
      stroke(255);
      strokeWeight(2);
    } else {
      noStroke();
    }

    fill(col);
    ellipse(x, y, 10, 10);
  }
}
class ToggleButton {
  float x, y, w, h;
  String label;
  boolean on = false;

  ToggleButton(float x, float y, float w, float h, String label) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.label = label;
  }

  void display() {
    stroke(0);
    fill(on ? color(0, 160, 80) : 230);
    rect(x, y, w, h, 5);
    fill(on ? 255 : 0);
    text(label, x + 10, y + 20);
  }

  void handleClick(float mx, float my) {
    if (mx > x && mx < x + w && my > y && my < y + h) {
      on = !on;
    }
  }
}

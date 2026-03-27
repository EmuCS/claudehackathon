// ==========================
// Widget (Button) Class
// ==========================
class Widget {
  float x, y, w, h;
  String label;
  Runnable action;
  
  Widget(float x, float y, float w, float h, String label, Runnable action) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.action = action;
  }
  
  void display() {
    fill(100, 150, 255);
    rect(x, y, w, h, 8);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(label, x + w/2, y + h/2);
  }
  
  boolean isClicked(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
  
  void onClick() {
    action.run();
  }
}

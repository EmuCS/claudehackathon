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
    stroke(255);
    strokeWeight(2);
    fill(backgroundBlack);
    rect(x, y, w, h, 8);
    fill(textGreen);
    textAlign(CENTER, CENTER);
    textFont(basicFont);
    textSize(20);
    text(label, x + w/2, y + h/2);
  }
  
  boolean isClicked(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
  
  void onClick() {
    action.run();
  }
}

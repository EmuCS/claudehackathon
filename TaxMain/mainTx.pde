// Main
PFont headingFont, basicFont;
color textGreen = color(50,255,0);
color backgroundBlack = color(0);
color buttonWhite = color(255);


Screen currentScreen;

HomeScreen homeScreen;
PayslipCalculatorScreen payslipScreen;
TaxExplainerScreen taxExplainer;

void setup() {
  size(800, 600);
  smooth(8);
  // Initialize screens
  homeScreen = new HomeScreen();
  payslipScreen = new PayslipCalculatorScreen();
  taxExplainer = new TaxExplainerScreen();
  
  // Set initial screen
  currentScreen = homeScreen;
  

  headingFont = createFont("Bitcount_Cursive-Regular.ttf", 40);
  basicFont = createFont("GemunuLibre-Light.ttf", 25);
}

void draw() {
  
  // Delegate display to current screen
  currentScreen.display();
}

void mousePressed() {
  // Delegate mouse events to current screen
  currentScreen.mousePressed();
}

void mouseDragged() {
  currentScreen.mouseDragged();
}

void mouseWheel(MouseEvent event) {
  float amount = event.getCount();  // +1 = down, -1 = up
  currentScreen.mouseScrolled(amount);
}

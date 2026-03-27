// Main


Screen currentScreen;

HomeScreen homeScreen;
PayslipCalculatorScreen payslipScreen;

void setup() {
  size(800, 600);
  
  // Initialize screens
  homeScreen = new HomeScreen();
  payslipScreen = new PayslipCalculatorScreen();
  
  // Set initial screen
  currentScreen = homeScreen;
}

void draw() {
  background(240);
  
  // Delegate display to current screen
  currentScreen.display();
}

void mousePressed() {
  // Delegate mouse events to current screen
  currentScreen.mousePressed();
}

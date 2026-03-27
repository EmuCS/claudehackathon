// ==========================
// Main Globals
// ==========================

Screen currentScreen;

import processing.data.Table;
import processing.data.TableRow;
import java.util.ArrayList;
import java.util.Collections;

PFont myFont;

// Quiz data
Table quizTable;
ArrayList<Question> allQuestions = new ArrayList<Question>();
int totalCorrectEver = 0;

// Screens
QuizScreen quizScreen;
HomeScreen homeScreen;
PayslipCalculatorScreen payslipScreen;

ProgressScreen progressScreen;

PensionScreen pensionScreen;
PensionGraphScreen pensionGraphScreen;


// ==========================
// Setup
// ==========================
void setup() {
  fullScreen();

  // Load quiz data from CSV
  loadQuizData();

  // Initialize screens
  homeScreen = new HomeScreen();
  payslipScreen = new PayslipCalculatorScreen();
  quizScreen = new QuizScreen();

  // Set initial screen
  currentScreen = homeScreen;
  progressScreen = new ProgressScreen();
  
  myFont = createFont("VerdanaPro-Bold-48", 32);  // font name, size
  textFont(myFont);
  
  pensionScreen = new PensionScreen();
  pensionGraphScreen = new PensionGraphScreen();

}


// ==========================
// Load CSV Data
// ==========================
void loadQuizData() {
  quizTable = loadTable("CSV/MCQQuestions.csv");  // no header assumed

  allQuestions.clear();
  totalCorrectEver = 0;

  for (int i = 0; i < quizTable.getRowCount(); i++) {
    TableRow row = quizTable.getRow(i);

    // Skip malformed rows (less than 8 columns)
    if (row.getColumnCount() < 8) {
      println("Skipping bad row at line " + (i + 1));
      continue;
    }

    Question q = new Question(row);
    allQuestions.add(q);

    if (q.everAnsweredCorrect) {
      totalCorrectEver++;
    }
  }
}


// ==========================
// Draw Loop
// ==========================
void draw() {
  background(240);

  // Delegate display to current screen
  currentScreen.display();
}


// ==========================
// Mouse Handling
// ==========================
void mousePressed() {
  // Delegate mouse events to current screen
  currentScreen.mousePressed();
}



// QUIZ ---------------------------------------------------

// ==========================
// Question Class
// ==========================
class Question {
  String text;
  String difficulty;
  String[] options = new String[4];
  int correctIndex;          
  boolean everAnsweredCorrect; 
  
  Question(TableRow row) {
    text = row.getString(0);
    difficulty = row.getString(1);
    
    options[0] = row.getString(2);
    options[1] = row.getString(3);
    options[2] = row.getString(4);
    options[3] = row.getString(5);
    
    String correctAnswer = row.getString(6);
    everAnsweredCorrect = row.getInt(7) == 1;
    
    correctIndex = 0;
    for (int i = 0; i < 4; i++) {
      if (options[i].equals(correctAnswer)) {
        correctIndex = i;
        break;
      }
    }
  }
}



// ==========================
// Quiz Screen (Fullscreen)
// ==========================
class QuizScreen extends Screen {
  ArrayList<Question> quizQuestions;
  int currentIndex;
  int score;
  boolean quizFinished;
  
  QuizScreen() {
    super();
    startNewQuiz();
  }
  
  void startNewQuiz() {
    quizQuestions = new ArrayList<Question>();
    score = 0;
    quizFinished = false;
    currentIndex = 0;
    
    ArrayList<Question> pool = new ArrayList<Question>();
    for (Question q : allQuestions) {
      if (!q.everAnsweredCorrect) pool.add(q);
    }
    if (pool.size() == 0) pool.addAll(allQuestions);

    Collections.shuffle(pool);
    int n = min(20, pool.size());
    for (int i = 0; i < n; i++) quizQuestions.add(pool.get(i));

    buildOptionButtons();
    buildReturnToProgressButton();
  }


  // ------------------------------------------------
  // Bottom-left button: Go to Progress Screen
  // ------------------------------------------------
  void buildReturnToProgressButton() {
    float btnW = width * 0.18;
    float btnH = height * 0.06;
    float x = width * 0.02;
    float y = height * 0.90;

    Widget returnBtn = new Widget(
      x, y, btnW, btnH,
      "Check Progress",
      () -> {
        currentScreen = progressScreen;
      }
    );

    widgets.add(returnBtn);
  }


  void buildOptionButtons() {
    widgets.clear();
    addHomeButton();
    buildReturnToProgressButton();
    
    if (quizQuestions.size() == 0) return;
    if (currentIndex >= quizQuestions.size()) return;
    
    Question q = quizQuestions.get(currentIndex);
    
    float btnWidth  = width * 0.35;
    float btnHeight = height * 0.06;
    float startX    = width * 0.5 - btnWidth/2;
    float startY    = height * 0.40;
    float gap       = height * 0.02;
    
    ArrayList<Integer> order = new ArrayList<Integer>();
    for (int i = 0; i < 4; i++) order.add(i);
    Collections.shuffle(order);
    
    for (int i = 0; i < 4; i++) {
      final int shuffledIndex = order.get(i);
    
      Widget optionBtn = new Widget(
        startX,
        startY + i * (btnHeight + gap),
        btnWidth,
        btnHeight,
        q.options[shuffledIndex],
        () -> handleAnswer(shuffledIndex)
      );
    
      widgets.add(optionBtn);
    }
  }
  
  void handleAnswer(int optionIndex) {
    if (quizFinished) return;
    if (currentIndex >= quizQuestions.size()) return;
    
    Question q = quizQuestions.get(currentIndex);
    
    if (optionIndex == q.correctIndex) {
      score++;
      if (!q.everAnsweredCorrect) {
        q.everAnsweredCorrect = true;
        totalCorrectEver++;
      }
    }
    
    currentIndex++;
    if (currentIndex < quizQuestions.size()) {
      buildOptionButtons();
    } else {
      quizFinished = true;
      buildFinishedWidgets();
    }
  }
  
  void buildFinishedWidgets() {
    widgets.clear();
    addHomeButton();
    buildReturnToProgressButton();

    Widget playAgainBtn = new Widget(
      width * 0.5 - width * 0.12,
      height * 0.65,
      width * 0.24,
      height * 0.08,
      "Play Again",
      () -> startNewQuiz()
    );
    widgets.add(playAgainBtn);
  }
  
  void display() {
    background(240);

    // APPLY CUSTOM FONT
    textFont(myFont);
    
    if (!quizFinished && quizQuestions.size() > 0 && currentIndex < quizQuestions.size()) {
      Question q = quizQuestions.get(currentIndex);
      
      fill(0);
      textAlign(CENTER, CENTER);
      
      textSize(height * 0.04);
      text("Question " + (currentIndex + 1) + " of " + quizQuestions.size(),
           width/2, height * 0.08);
      
      textSize(height * 0.045);
      text(q.text,
           width * 0.1, height * 0.12,
           width * 0.8, height * 0.25);
      
      displayWidgets();
      
    } else {
      fill(0);
      textAlign(CENTER, CENTER);

      textFont(myFont);
      
      textSize(height * 0.05);
      text("Quiz Complete!", width/2, height * 0.15);
      
      textSize(height * 0.035);
      text("Score: " + score + " / " + quizQuestions.size(),
           width/2, height * 0.22);
      
      float barWidth  = width * 0.5;
      float barHeight = height * 0.04;
      float barX = width/2 - barWidth/2;
      float barY = height * 0.40;
      
      float fraction = (allQuestions.size() > 0)
        ? (float)totalCorrectEver / (float)allQuestions.size()
        : 0;
      
      fill(200);
      rect(barX, barY, barWidth, barHeight);
      
      fill(0, 180, 0);
      rect(barX, barY, barWidth * fraction, barHeight);
      
      fill(0);
      textSize(height * 0.03);
      text("Total questions correct: " + totalCorrectEver + " / " + allQuestions.size(),
           width/2, barY - height * 0.05);
      
      displayWidgets();
    }
  }
  
  void mousePressed() {
    super.mousePressed();
  }
}


// Screen ------------------------


// ==========================
// Screen Base Class (Fullscreen)
// ==========================
abstract class Screen {
  ArrayList<Widget> widgets;
  
  Screen() {
    widgets = new ArrayList<Widget>();
    addHomeButton();
  }
  
  void addHomeButton() {
    if (!(this instanceof HomeScreen)) {
      float btnW = width * 0.10;
      float btnH = height * 0.05;
      float x = width * 0.02;
      float y = height * 0.02;

      Widget homeBtn = new Widget(
        x, y, btnW, btnH,
        "Home",
        () -> { currentScreen = homeScreen; }
      );
      widgets.add(homeBtn);
    }
  }
  
  void displayWidgets() {
    for (Widget w : widgets) {
      w.display();
    }
  }
  
  abstract void display();
  
  void mousePressed() {
    Widget[] copy = widgets.toArray(new Widget[0]);
    for (Widget w : copy) {
      if (w.isClicked(mouseX, mouseY)) {
        w.onClick();
        return;
      }
    }
  }
}



// ==========================
// Home Screen (Fullscreen)
// ==========================
class HomeScreen extends Screen {

  HomeScreen() {
    super();

    float btnW = width * 0.25;
    float btnH = height * 0.08;
    float centerX = width * 0.5 - btnW/2;

    Widget payslipBtn = new Widget(
      centerX,
      height * 0.35,
      btnW,
      btnH,
      "Payslip Calculator",
      () -> { currentScreen = payslipScreen; }
    );
    widgets.add(payslipBtn);
    
    Widget quizBtn = new Widget(
      centerX,
      height * 0.50,
      btnW,
      btnH,
      "Start Quiz",
      () -> { currentScreen = quizScreen; }
    );
    widgets.add(quizBtn);
    
    
    Widget pensionBtn = new Widget(
      centerX,
      height * 0.65,
      btnW,
      btnH,
      "Pension Forecast",
      () -> { currentScreen = pensionScreen; }
    );
    widgets.add(pensionBtn);
  }

  void display() {
    fill(0);
    textSize(height * 0.06);
    textAlign(CENTER, CENTER);
    text("Welcome to Payslip Explainer", width/2, height * 0.15);

    displayWidgets();
  }
}



// ==========================
// Payslip Calculator Screen (Fullscreen)
// ==========================
class PayslipCalculatorScreen extends Screen {
  
  PayslipCalculatorScreen() {
    super();
  }
  
  void display() {
    fill(0);
    textSize(height * 0.05);
    textAlign(CENTER, CENTER);
    text("Payslip Calculator Screen", width/2, height * 0.15);
    
    // Placeholder input box
    float boxW = width * 0.40;
    float boxH = height * 0.08;
    float boxX = width * 0.5 - boxW/2;
    float boxY = height * 0.40;

    fill(50);
    rect(boxX, boxY, boxW, boxH);

    fill(255);
    textSize(height * 0.03);
    textAlign(LEFT, CENTER);
    text("Gross Salary Input (placeholder)", boxX + width * 0.01, boxY + boxH/2);

    displayWidgets();
  }
}

// ==========================
// Progress Screen (Fullscreen)
// ==========================
// ==========================
// Progress Screen (Fullscreen)
// ==========================
class ProgressScreen extends Screen {

  ProgressScreen() {
    super();
  }

  void display() {
    background(240);

    fill(0);
    textAlign(CENTER, CENTER);

    textSize(height * 0.05);
    text("Your Quiz Progress", width/2, height * 0.15);

    // Progress bar
    float barWidth  = width * 0.5;
    float barHeight = height * 0.04;
    float barX = width/2 - barWidth/2;
    float barY = height * 0.40;

    float fraction = (allQuestions.size() > 0)
      ? (float)totalCorrectEver / (float)allQuestions.size()
      : 0;

    fill(200);
    rect(barX, barY, barWidth, barHeight);

    fill(0, 180, 0);
    rect(barX, barY, barWidth * fraction, barHeight);

    fill(0);
    textSize(height * 0.03);
    text("Total questions correct: " + totalCorrectEver + " / " + allQuestions.size(),
         width/2, barY - height * 0.05);

    // Return to quiz button
    Widget returnBtn = new Widget(
      width * 0.5 - width * 0.12,
      height * 0.65,
      width * 0.24,
      height * 0.08,
      "Return to Quiz",
      () -> {
        currentScreen = quizScreen;   // resume quiz at currentIndex
      }
    );

    widgets.clear();
    addHomeButton();
    widgets.add(returnBtn);

    displayWidgets();
  }
}


class PensionScreen extends Screen {

  float age = 25;
  float salary = 40000;
  float retirementAge = 65;
  float growthRate = 0.04; // 4% compounding
  String[] riskOptions = {"Low (3%)","Medium (4%)","High (5%)"};
  int riskIndex = 1;

  Widget agePlus, ageMinus, salaryPlus, salaryMinus, retirePlus, retireMinus, riskBtn, viewGraphBtn;

  ArrayList<PensionYear> forecast = new ArrayList<PensionYear>();

  PensionScreen() {
    super();
    buildWidgets();
  }

  void buildWidgets() {
    widgets.clear();
    addHomeButton();

    float btnW = width*0.05;
    float btnH = height*0.06;
    float xLeft = width*0.25 + 75;
    float xRight = width*0.55 + 75;
    float yStart = height*0.25;
    float gap = height*0.09;

    // Age +
    agePlus = new Widget(xLeft + 550, yStart, btnW, btnH, "+", () -> { age++; computeForecast(); });
    ageMinus = new Widget(xRight, yStart, btnW, btnH, "-", () -> { if(age>18) age--; computeForecast(); });

    // Salary +
    salaryPlus = new Widget(xLeft + 550, yStart+gap, btnW, btnH, "+", () -> { salary += 1000; computeForecast(); });
    salaryMinus = new Widget(xRight, yStart+gap, btnW, btnH, "-", () -> { if(salary>1000) salary -= 1000; computeForecast(); });

    // Retirement Age +
    retirePlus = new Widget(xLeft + 550, yStart+gap*2, btnW, btnH, "+", () -> { if(retirementAge<75) retirementAge++; computeForecast(); });
    retireMinus = new Widget(xRight, yStart+gap*2, btnW, btnH, "-", () -> { if(retirementAge>age+1) retirementAge--; computeForecast(); });

    // Risk / growth
    riskBtn = new Widget(width*0.4 + 310, yStart+gap*3 - 10, btnW*2, btnH, "Risk: "+riskOptions[riskIndex], 
      () -> { riskIndex = (riskIndex+1)%riskOptions.length; updateGrowth(); computeForecast(); });
      
    // View Graph 
    viewGraphBtn = new Widget(width*0.35, height*0.75, width*0.3, btnH, "View Graph", 
      () -> { pensionGraphScreen.setForecast(forecast); currentScreen = pensionGraphScreen; });

    widgets.add(agePlus);
    widgets.add(ageMinus);
    widgets.add(salaryPlus);
    widgets.add(salaryMinus);
    widgets.add(retirePlus);
    widgets.add(retireMinus);
    widgets.add(riskBtn);
    widgets.add(viewGraphBtn);

    computeForecast();
  }

  void updateGrowth() {
    switch(riskIndex) {
      case 0: growthRate = 0.03; break;
      case 1: growthRate = 0.04; break;
      case 2: growthRate = 0.05; break;
    }
    riskBtn.label = "Risk: "+riskOptions[riskIndex];
  }

  void computeForecast() {
    forecast.clear();
    int years = int(retirementAge - age);
    float pot = 0;

    for(int i=0;i<years;i++){
      int year = i+1;
      float empRate = year<=3?0.015f:(year<=6?0.03f:(year<=9?0.045f:0.06f));
      float contributionEmp = salary*empRate;
      float contributionEmployer = salary*empRate;
      float contributionState = salary*(empRate/3); // simple proportional

      pot += contributionEmp + contributionEmployer + contributionState;
      pot *= (1+growthRate);

      PensionYear py = new PensionYear();
      py.year = year;
      py.employeeContribution = contributionEmp;
      py.employerContribution = contributionEmployer;
      py.stateContribution = contributionState;
      py.totalPot = pot;

      forecast.add(py);
    }
  }

  void display() {
    background(240);
    fill(0);
    textAlign(LEFT, CENTER);
    textSize(height*0.04);
    text("Age: "+int(age), width*0.3, height*0.25+height*0.02);
    text("Salary: €"+int(salary), width*0.3, height*0.25+height*0.11);
    text("Retirement Age: "+int(retirementAge), width*0.3, height*0.25+height*0.20);
    text("Estimated Growth: "+int(growthRate*100)+"%", width*0.3, height*0.25+height*0.29);

    displayWidgets();
  }

  void mousePressed() {
    super.mousePressed();
  }
}



class PensionGraphScreen extends Screen {

  ArrayList<PensionYear> forecast = new ArrayList<PensionYear>();

  void setForecast(ArrayList<PensionYear> f) {
    forecast = f;
  }

  PensionGraphScreen() {
    super();
  }

  void display() {
  
    background(245);
  
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(height * 0.05);
    text("Pension Forecast", width/2, height*0.07);
  
    if (forecast.size() > 0) {
  
      float graphX = width * 0.1;
      float graphY = height * 0.15;
      float graphW = width * 0.8;
      float graphH = height * 0.55; // slightly smaller to make space for text below
  
      // ===== Find max value
      float maxPot = 0;
      for (PensionYear py : forecast) {
        maxPot = max(maxPot, py.totalPot);
      }
  
      // ===== Axes
      stroke(0);
      line(graphX, graphY, graphX, graphY + graphH);
      line(graphX, graphY + graphH, graphX + graphW, graphY + graphH);
  
      // ===== Y-axis labels
      fill(0);
      textSize(14);
      for (int i = 0; i <= 5; i++) {
        float val = maxPot * i / 5.0;
        float y = graphY + graphH - (i / 5.0) * graphH;
  
        text("€" + int(val), graphX - 60, y);
        stroke(200);
        line(graphX, y, graphX + graphW, y);
        stroke(0);
      }
  
      int n = forecast.size();
      float barSpacing = graphW / n;
      float barW = barSpacing * 0.6;
  
      // ===== Bars
      for (int i = 0; i < n; i++) {
        PensionYear py = forecast.get(i);
  
        float x = graphX + i * barSpacing + barSpacing * 0.2;
  
        float totalH = (py.totalPot / maxPot) * graphH;
        float yTop = graphY + graphH - totalH;
  
        // Total pot background
        fill(180, 180, 255);
        rect(x, yTop, barW, totalH);
  
        float runningY = yTop;
  
        float empH = (py.employeeContribution / py.totalPot) * totalH;
        fill(100, 150, 255);
        rect(x, runningY, barW, empH);
        runningY += empH;
  
        float employerH = (py.employerContribution / py.totalPot) * totalH;
        fill(255, 150, 100);
        rect(x, runningY, barW, employerH);
        runningY += employerH;
  
        float stateH = (py.stateContribution / py.totalPot) * totalH;
        fill(100, 255, 150);
        rect(x, runningY, barW, stateH);
  
        // X labels
        fill(0);
        textSize(12);
        text("Y" + py.year, x + barW/2, graphY + graphH + 20);
      }
  
      // ===== Legend (MOVED LEFT)
      float lx = width * 0.65;   // moved from 0.75 → 0.65
      float ly = height * 0.2;
  
      textAlign(LEFT, CENTER);
      textSize(14);
  
      fill(100,150,255);
      rect(lx, ly, 15, 15);
      fill(0);
      text("Employee", lx + 25, ly + 8);
  
      fill(255,150,100);
      rect(lx, ly + 25, 15, 15);
      fill(0);
      text("Employer", lx + 25, ly + 33);
  
      fill(100,255,150);
      rect(lx, ly + 50, 15, 15);
      fill(0);
      text("State", lx + 25, ly + 58);
  
      fill(180,180,255);
      rect(lx, ly + 75, 15, 15);
      fill(0);
      text("Total Pot", lx + 25, ly + 83);
  
  
      // ===== DECADE INSIGHTS (NEW FEATURE)
      textAlign(CENTER, CENTER);
      fill(0);
      textSize(16);
  
      float textY = graphY + graphH + 60;
  
      int step = max(10, n / 4); // dynamic spacing (every ~10 years or 4 chunks)
  
      for (int i = step; i < n; i += step) {
        float gain = forecast.get(i).totalPot - forecast.get(i - step).totalPot;
  
        String msg = "Years " + (i-step+1) + "-" + (i+1) +
                     ": +" + "€" + int(gain);
  
        text(msg, width/2, textY);
        textY += 25;
      }
    }
  
    displayWidgets();
  }

  void mousePressed() {
    super.mousePressed();
  }
}


class PensionYear {
  int year;                   
  float employeeContribution;  
  float employerContribution;  
  float stateContribution;     
  float totalPot;              
}


// Widget ---------------------------------------------------------


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

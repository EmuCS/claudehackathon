// =====================================================
// taxÉIRE — Explain My Payslip
// Main File (UI, Screens, Tax Logic)
// =====================================================

int screen = 0; // 0 = inputs, 1 = credits, 2 = results

// Input fields
InputField nameField, salaryField, pensionField, healthField, loanField, ageField, tuitionField, rentField;
String period = "Monthly";

// Toggles
YesNoToggle personalCreditToggle, payeCreditToggle, homeCarerToggle, singleParentToggle, rentCreditToggle, tuitionCreditToggle;


// Calculated values
double annualIncome, pension, health, studentLoan, tuitionFees, rentPaid;
double taxableIncome, paye, prsi, usc, credits, totalTax, netIncome;
int age;

// Explanation text
String selectedExplanation = "";

// Colors
int payeCol = color(255, 120, 120);
int prsiCol = color(255, 190, 120);
int uscCol = color(255, 230, 120);
int creditsCol = color(120, 190, 255);

void setup() {
  size(900, 650);
  textFont(createFont("Arial", 16));

  // Input fields
  nameField    = new InputField(250, 120, 250, 30, "Name");
  salaryField  = new InputField(250, 170, 250, 30, "Gross Salary (€)");
  pensionField = new InputField(250, 270, 250, 30, "Pension (€)");
  healthField  = new InputField(250, 320, 250, 30, "Health Insurance (€)");
  loanField    = new InputField(250, 370, 250, 30, "Student Loan (€)");
  ageField     = new InputField(250, 420, 100, 30, "Age");
  tuitionField = new InputField(250, 470, 250, 30, "Tuition Fees (€)");
  rentField    = new InputField(250, 520, 250, 30, "Annual Rent (€)");

  // Credit toggles
  personalCreditToggle = new YesNoToggle(200, 140, "Personal Tax Credit");
  payeCreditToggle     = new YesNoToggle(200, 190, "PAYE Credit");
  homeCarerToggle      = new YesNoToggle(200, 240, "Home Carer Credit");
  singleParentToggle   = new YesNoToggle(200, 290, "Single Parent (SPCCC)");
  rentCreditToggle     = new YesNoToggle(200, 340, "Rent Credit");
  tuitionCreditToggle  = new YesNoToggle(200, 390, "Tuition Credit");
}

void draw() {
  background(245);

  if (screen == 0) drawInputScreen();
  if (screen == 1) drawCreditsScreen();
  if (screen == 2) drawResultsScreen();
}

// =====================================================
// SCREEN 0 — BASIC INPUTS
// =====================================================

void drawInputScreen() {
  fill(0);
  textSize(26);
  text("taxÉIRE — Explain My Payslip", 260, 50);
  textSize(16);

  text("Name:", 150, 120);
  nameField.display();

  text("Gross Salary (€):", 150, 170);
  salaryField.display();

  text("Pay Period:", 150, 220);
  fill(0);
  text(period + " (click to toggle)", 250, 220);

  text("Pension (€):", 150, 270);
  pensionField.display();

  text("Health Insurance (€):", 150, 320);
  healthField.display();

  text("Student Loan (€):", 150, 370);
  loanField.display();

  text("Age:", 150, 420);
  ageField.display();

  text("Tuition Fees (€):", 150, 470);
  tuitionField.display();

  // Next button
  fill(0, 120, 255);
  rect(350, 540, 200, 50, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Next: Credits", 450, 565);
  textAlign(LEFT, BASELINE);
}

// =====================================================
// SCREEN 1 — TAX CREDIT TOGGLES
// =====================================================

void drawCreditsScreen() {
  fill(0);
  textSize(24);
  text("Tax Credits Eligibility", 320, 60);
  textSize(16);

  personalCreditToggle.display();
  payeCreditToggle.display();
  homeCarerToggle.display();
  singleParentToggle.display();
  rentCreditToggle.display();
  tuitionCreditToggle.display();

  if (rentCreditToggle.isYes()) {
    text("Annual Rent (€):", 150, 430);
    rentField.display();
  }

  if (tuitionCreditToggle.isYes()) {
    text("Tuition Fees (€):", 150, 480);
    tuitionField.display();
  }

  // Back button
  fill(150);
  rect(200, 540, 150, 50, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Back", 275, 565);

  // Calculate button
  fill(0, 160, 80);
  rect(450, 540, 200, 50, 10);
  fill(255);
  text("Calculate Tax", 550, 565);
  textAlign(LEFT, BASELINE);
}
// =====================================================
// SCREEN 2 — RESULTS + PIE CHART + EXPLANATIONS
// =====================================================

void drawResultsScreen() {
  fill(0);
  textSize(22);
  text("Results for " + nameField.text, 50, 50);
  textSize(16);

  text("Annual Gross Income: €" + nf((float)annualIncome, 0, 2), 50, 100);
  text("Taxable Income: €" + nf((float)taxableIncome, 0, 2), 50, 130);

  text("PAYE: €" + nf((float)paye, 0, 2), 50, 180);
  text("PRSI: €" + nf((float)prsi, 0, 2), 50, 210);
  text("USC: €" + nf((float)usc, 0, 2), 50, 240);
  text("Credits: €" + nf((float)credits, 0, 2), 50, 270);
  text("Total Tax: €" + nf((float)totalTax, 0, 2), 50, 300);
  text("Net Income: €" + nf((float)netIncome, 0, 2), 50, 330);

  drawPieChart(600, 250, 250);

  drawExplanationButton(500, 450, "PAYE", payeCol);
  drawExplanationButton(620, 450, "PRSI", prsiCol);
  drawExplanationButton(500, 500, "USC", uscCol);
  drawExplanationButton(620, 500, "Credits", creditsCol);

  fill(240);
  rect(50, 380, 400, 200, 10);
  fill(0);
  text("Explanation:", 60, 405);
  text(selectedExplanation, 60, 430, 380, 140);

  fill(150);
  rect(50, 560, 150, 40, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Back", 125, 580);
  textAlign(LEFT, BASELINE);
}

// =====================================================
// PIE CHART
// =====================================================

void drawPieChart(float cx, float cy, float diameter) {
  double total = paye + prsi + usc;
  if (total <= 0) return;

  float start = 0;

  float anglePAYE = (float)(TWO_PI * (paye / total));
  fill(payeCol);
  arc(cx, cy, diameter, diameter, start, start + anglePAYE);
  start += anglePAYE;

  float anglePRSI = (float)(TWO_PI * (prsi / total));
  fill(prsiCol);
  arc(cx, cy, diameter, diameter, start, start + anglePRSI);
  start += anglePRSI;

  float angleUSC = (float)(TWO_PI * (usc / total));
  fill(uscCol);
  arc(cx, cy, diameter, diameter, start, start + angleUSC);
}

void drawExplanationButton(int x, int y, String label, int col) {
  fill(col);
  rect(x, y, 100, 35, 5);
  fill(0);
  text(label, x + 30, y + 22);
}

// =====================================================
// MOUSE HANDLING
// =====================================================

void mousePressed() {
  if (screen == 0) {
    nameField.handleClick(mouseX, mouseY);
    salaryField.handleClick(mouseX, mouseY);
    pensionField.handleClick(mouseX, mouseY);
    healthField.handleClick(mouseX, mouseY);
    loanField.handleClick(mouseX, mouseY);
    ageField.handleClick(mouseX, mouseY);
    tuitionField.handleClick(mouseX, mouseY);

    if (mouseX > 250 && mouseX < 450 && mouseY > 200 && mouseY < 230) {
      period = period.equals("Monthly") ? "Weekly" : "Monthly";
    }

    if (mouseX > 350 && mouseX < 550 && mouseY > 540 && mouseY < 590) {
      screen = 1;
    }
  }

  else if (screen == 1) {
    personalCreditToggle.handleClick(mouseX, mouseY);
    payeCreditToggle.handleClick(mouseX, mouseY);
    homeCarerToggle.handleClick(mouseX, mouseY);
    singleParentToggle.handleClick(mouseX, mouseY);
    rentCreditToggle.handleClick(mouseX, mouseY);
    tuitionCreditToggle.handleClick(mouseX, mouseY);

    if (rentCreditToggle.isYes) rentField.handleClick(mouseX, mouseY);
    if (tuitionCreditToggle.isYes) tuitionField.handleClick(mouseX, mouseY);

    if (mouseX > 200 && mouseX < 350 && mouseY > 540 && mouseY < 590) {
      screen = 0;
    }

    if (mouseX > 450 && mouseX < 650 && mouseY > 540 && mouseY < 590) {
      calculateTax();
      screen = 2;
    }
  }

  else if (screen == 2) {
    if (mouseX > 50 && mouseX < 200 && mouseY > 560 && mouseY < 600) {
      screen = 1;
    }

    if (mouseX > 500 && mouseX < 600 && mouseY > 450 && mouseY < 485)
      selectedExplanation = "PAYE is income tax charged at 20% up to €42k and 40% above.";
    if (mouseX > 620 && mouseX < 720 && mouseY > 450 && mouseY < 485)
      selectedExplanation = "PRSI is 4% of your income and funds social welfare.";
    if (mouseX > 500 && mouseX < 600 && mouseY > 500 && mouseY < 535)
      selectedExplanation = "USC is a multi-band tax applied to all income.";
    if (mouseX > 620 && mouseX < 720 && mouseY > 500 && mouseY < 535)
      selectedExplanation = "Credits reduce the tax you owe.";
  }
}

// =====================================================
// KEY HANDLING
// =====================================================

void keyTyped() {
  if (screen == 0) {
    nameField.keyTyped(key);
    salaryField.keyTyped(key);
    pensionField.keyTyped(key);
    healthField.keyTyped(key);
    loanField.keyTyped(key);
    ageField.keyTyped(key);
    tuitionField.keyTyped(key);
  }

  if (screen == 1) {
    rentField.keyTyped(key);
    tuitionField.keyTyped(key);
  }
}

// =====================================================
// TAX CALCULATION
// =====================================================

void calculateTax() {
  annualIncome = parseMoney(salaryField.text);
  pension      = parseMoney(pensionField.text);
  health       = parseMoney(healthField.text);
  studentLoan  = parseMoney(loanField.text);
  tuitionFees  = parseMoney(tuitionField.text);
  rentPaid     = parseMoney(rentField.text);
  age          = (int)parseMoney(ageField.text);

  if (period.equals("Weekly")) annualIncome *= 52;
  else annualIncome *= 12;

  taxableIncome = annualIncome - pension - health - studentLoan;
  if (taxableIncome < 0) taxableIncome = 0;

  double cutoff = 42000;
  double tax20 = Math.min(taxableIncome, cutoff) * 0.20;
  double tax40 = Math.max(0, taxableIncome - cutoff) * 0.40;
  paye = tax20 + tax40;

  prsi = taxableIncome * 0.04;

  usc = calculateUSC(taxableIncome);

  credits = 0;
  
  if (personalCreditToggle.isYes()) credits += 1875;
  if (payeCreditToggle.isYes()) credits += 1875;
  if (homeCarerToggle.isYes()) credits += 1800;
  if (singleParentToggle.isYes()) credits += 1750;
  
  if (rentCreditToggle.isYes()) {
    credits += Math.min(750, rentPaid * 0.20);
  }
  
  if (tuitionCreditToggle.isYes()) {
  credits += tuitionFees * 0.20;
}
  totalTax = paye + prsi + usc - credits;
  if (totalTax < 0) totalTax = 0;

  netIncome = annualIncome - totalTax;
}

double calculateUSC(double income) {
  double uscTotal = 0;
  double remaining = income;

  double band1 = 12012;
  double band2 = 10908;
  double band3 = 47124;

  double at1 = Math.min(remaining, band1);
  uscTotal += at1 * 0.005;
  remaining -= at1;

  if (remaining > 0) {
    double at2 = Math.min(remaining, band2);
    uscTotal += at2 * 0.02;
    remaining -= at2;
  }

  if (remaining > 0) {
    double at3 = Math.min(remaining, band3);
    uscTotal += at3 * 0.045;
    remaining -= at3;
  }

  if (remaining > 0) uscTotal += remaining * 0.08;

  return uscTotal;
}

double parseMoney(String s) {
  try { return Double.parseDouble(s.trim()); }
  catch (Exception e) { return 0; }
}
String getExplanation(String label) {
  if (label.equals("Personal Tax Credit"))
    return "A universal credit (€1,875) available to all taxpayers.";
  if (label.equals("PAYE Credit"))
    return "A credit (€1,875) for employees paying tax through PAYE.";
  if (label.equals("Home Carer Credit"))
    return "A credit (€1,800) for a spouse who cares for a dependent at home.";
  if (label.equals("Single Parent (SPCCC)"))
    return "A credit (€1,750) for single parents with primary custody.";
  if (label.equals("Rent Credit"))
    return "A credit (20% of rent, max €750) for eligible renters.";
  if (label.equals("Tuition Credit"))
    return "A credit worth 20% of qualifying tuition fees.";

  return "";
}

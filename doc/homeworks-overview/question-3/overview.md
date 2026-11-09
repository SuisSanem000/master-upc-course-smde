# Question 3: Linear Regression Analysis — Master Study & Meeting Guide

This guide breaks down **Question 3** of the assignment into simple, easy-to-understand concepts. It covers predictive modeling, regression assumptions, dummy variables, model comparison, and validation, preparing you in case you volunteer to take on Question 3 for the team!

---

## 1. The Big Picture: What is Question 3 Really About?

In Question 3, our goal is to **predict an athletic outcome**: how far a person can jump in the standing broad jump test (`broad_jump_cm`).

Instead of guessing, we use **Linear Regression** to build a mathematical formula that predicts jump distance from other measurements:
1. First, we look at single numerical predictors (like grip strength, body fat, or sit-ups) to see which one alone is the best predictor (**Simple Linear Regression**).
2. Second, we combine the top two numerical predictors together to see if two variables predict better than one (**Multiple Linear Regression**).
3. Third, we add categorical groups like age categories (`age_cat`) or gender to see if they shift the prediction line up or down (**Dummy Variable Regression**).
4. Fourth, we formally compare all models to pick the single best model that balances accuracy and simplicity.
5. Finally, we test our chosen model on new, unseen data (**Train/Test Split**) to prove that our formula really works and does not overfit.

---

## 2. Connections to Course Materials

| Question 3 Part | Relevant Course Material | What the Professor Taught |
| :--- | :--- | :--- |
| **Q3.a** | **Session 9 & Session 10 Lab** (`Simple_Linear_Regression_SMDE_Fall26.pdf`, `Lab_SMDE_Simple_Linear_Regression.R`) | Fitting simple regression with `lm(y ~ x)`, checking correlation with `cor()`, checking assumptions (linearity, normality of residuals, homoscedasticity with `bptest()`), and interpreting slope and intercept. |
| **Q3.b** | **Session 12 Lab** (`Lab_Multiple_Linear_Regression_SMDE.R`) | Fitting multiple regression `lm(y ~ x1 + x2)`, checking multicollinearity with `car::vif()`, and comparing models using a Partial F-test (`anova(model1, model2)`). |
| **Q3.c** | **Session 10 Lab & Session 12 Lab** (`Lab_SMDE_Simple_Linear_Regression.R`, lines 145–165) | Adding factors to regression (dummy variables). How to interpret the baseline level and the shift in intercept for other categories. |
| **Q3.d** | **Session 12 Lab** (`Lab_Multiple_Linear_Regression_SMDE.R`, lines 110–135) | Comparing nested models with Partial F-tests, Adjusted $R^2$, AIC, and BIC. |
| **Q3.e** | **Session 10 Lab & Session 12 Lab** (`Lab_SMDE_Simple_Linear_Regression.R`, lines 115–140) | Model validation: splitting data into 67%/70% train and 33%/30% test sets, predicting on the test set, and calculating Root Mean Square Error (RMSE). |

---

## 3. Subquestion Breakdown: Step-by-Step

### Part a: Best Simple Linear Regression (2.5 pts)
- **Target**: Predict `broad_jump_cm` using one numerical variable from: `body_fat_pct`, `grip_force`, or `sit_ups`.
- **What to do**:
  1. Calculate correlations with `broad_jump_cm`:
     - `grip_force`: very strong positive correlation ($r \approx +0.70$). Stronger grip strongly correlates with greater jump distance.
     - `sit_ups`: moderate-to-strong positive correlation ($r \approx +0.65$).
     - `body_fat_pct`: strong negative correlation ($r \approx -0.60$). Higher fat percentage strongly reduces jump distance.
  2. Fit simple models: `lm(broad_jump_cm ~ grip_force)`, `lm(broad_jump_cm ~ sit_ups)`, and `lm(broad_jump_cm ~ body_fat_pct)`.
  3. Select the best one: `grip_force` yields the highest $R^2$ and lowest residual error.
  4. Check assumptions (residuals vs. fitted, Q-Q plot, Breusch-Pagan test).
  5. Interpret the slope ($\beta_1$): For every 1 kg increase in grip force, the predicted broad jump distance increases by $\approx \hat{\beta}_1$ cm.
- **Teammate Status**: Unstarted template in `R/Q3.R`.

---

### Part b: Multiple Linear Regression with Two Predictors (2.5 pts)
- **What to do**:
  1. Take the top two numerical predictors (e.g., `grip_force` and `sit_ups`, or `grip_force` and `body_fat_pct`).
  2. Fit the model: `mlr <- lm(broad_jump_cm ~ grip_force + sit_ups, data = body)`.
  3. Check multicollinearity with `car::vif(mlr)`. Both VIF values will be well below 5, proving no harmful collinearity.
  4. Compare with the simple model from Part a using a Partial F-test:
     `anova(slr_best, mlr)`
  5. Explain why it is better: The $F$-test has $p < 0.001$, and Adjusted $R^2$ increases noticeably. Grip strength captures upper-body/overall strength, while sit-ups capture core endurance, giving a more complete prediction.
- **Teammate Status**: Unstarted.

---

### Part c: Adding Categorical Factors (3.0 pts)
- **Subpart (i) — Adding Age Categories (`age_cat`)**:
  - Model: `lm(broad_jump_cm ~ grip_force + sit_ups + age_cat, data = body)`.
  - How to interpret: The baseline category is `<30`. The coefficients for `30-39`, `40-49`, and `50+` are negative. They show how many fewer centimeters an older person jumps compared to someone under 30 who has the exact same grip strength and sit-up score.
- **Subpart (ii) — Adding Gender (`gender`)**:
  - Model: `lm(broad_jump_cm ~ grip_force + sit_ups + gender, data = body)`.
  - How to interpret: The baseline category is `Female`. The coefficient for `Male` is positive, showing the average additional centimeters jumped by a male compared to a female with the same grip strength and sit-up count.
- **Teammate Status**: Unstarted.

---

### Part d: Choosing the Best Model (1.0 pt)
- **What to do**:
  - Compare the 4 candidate models in a single table:
    1. 2-predictor numerical model
    2. Numerical model + `age_cat`
    3. Numerical model + `gender`
    4. Full model (Numerical predictors + `age_cat` + `gender`)
  - Compare their Adjusted $R^2$, Residual Standard Error, AIC, BIC, and Partial F-tests.
  - Choose the model that provides high explanatory power while remaining simple and interpretable.
- **Teammate Status**: Unstarted.

---

### Part e: Diagnostic Validity & Predictive Testing (1.0 pt)
- **What to do**:
  1. **Diagnostic Plots**: Check the 4 standard residual plots (`plot(final_model)`): Linearity, Normality, Homoscedasticity, and Influential points.
  2. **Train/Test Split**:
     - Split data into 70% training and 30% testing:
       ```r
       set.seed(123)
       n <- nrow(body)
       train_idx <- sample(1:n, 0.7 * n)
       train_set <- body[train_idx, ]
       test_set  <- body[-train_idx, ]
       ```
     - Train model on `train_set`.
     - Predict on `test_set` and calculate test RMSE:
       ```r
       pred <- predict(model, newdata = test_set)
       rmse_test <- sqrt(mean((test_set$broad_jump_cm - pred)^2))
       ```
     - Compare $RMSE_{\text{train}}$ and $RMSE_{\text{test}}$. Since they are very close, the model generalizes well to new data.
- **Teammate Status**: Unstarted.

---

## 4. Key Talking Points for Question 3

If you want to offer to take on Question 3 during the 8:00 PM meeting, here is what you can say:

1. **Clear Road Map**:
   > *"Question 3 is very structured: we screen the numerical predictors for broad jump, fit the best simple linear model, expand it to a two-variable model, add age and gender as dummy factors, and then validate it with a 70/30 train-test split. The professor showed this exact workflow in Lab 10 and Lab 12."*

2. **Offering to Lead Question 3**:
   > *"Since Question 1 is mostly written by Xiang and Question 2 is ANOVA, I can take responsibility for developing the R script and initial draft for Question 3. I have reviewed the required tests and validation steps, and can have the initial code and tables ready for us to review together."*


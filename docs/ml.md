# PahadiPulse — Machine Learning & Optimization Engine

## 1. Regional Pressure Scoring Model

The core regional pressure score is calculated continuously:
$$\text{Pressure Score} = \sum w_i \cdot S_i$$
Where:
- $w_{\text{tourism}} = 0.30$ (Current visitors vs capacity ratio, hotel occupancy rate)
- $w_{\text{water}} = 0.25$ (Municipal tanker deficit, ground table depletion index)
- $w_{\text{waste}} = 0.20$ (Daily solid waste generation vs clearance efficiency)
- $w_{\text{traffic}} = 0.15$ (Average vehicle delay on entry toll / ghat bottlenecks)
- $w_{\text{environment}} = 0.10$ (Monsoon rainfall, slope stability, landslide hazard alerts)

---

## 2. 7-Day Time-Series & Regression Pressure Forecaster

### Model Architecture
- **Algorithm**: Gradient Boosting Regressor / Random Forest with Ridge regularized trend baseline.
- **Input Features**:
  1. Historical 14-day rolling mean pressure
  2. Day of the week (Friday–Sunday weekend surge multiplier)
  3. National holiday / long-weekend binary flag
  4. Seasonal index (Char Dham season, summer rush, monsoon risk)
  5. Active open citizen reports count in 15km radius
- **Output**: Point estimate $\hat{y}_t$ for days $t \in [1, 7]$ with 95% prediction intervals $[\hat{y}_{\text{lower}}, \hat{y}_{\text{upper}}]$.

---

## 3. AI Citizen Report Category & Severity Classifier

### Natural Language Processing Pipeline
1. **Text Preprocessing**: Tokenization, mountain vocabulary normalizer (e.g. *chakka-jam*, *khal*, *gadhera*, *malba*).
2. **Feature Extraction**: TF-IDF n-gram vectorization ($n \in \{1, 2\}$) with sublinear term frequency scaling.
3. **Multi-Task Classification**:
   - **Category Classifier**: Logistic Regression with Balanced Class Weights predicting 9 classes (`WATER`, `WASTE`, `ROAD`, `TRAFFIC`, `HEALTH`, `CONNECTIVITY`, `TOURISM`, `ENVIRONMENT`, `OTHER`).
   - **Severity Regressor / Classifier**: Calibrated scoring from 1 (minor) to 5 (critical emergency).
   - **Rule-based heuristic fallback** for high-risk terms (e.g. "landslide blocked", "dry tap for 4 days", "bridge cracked").

---

## 4. Pressure-Aware Multi-Objective Itinerary Optimizer

### Optimization Objective
$$\max \left( \sum_{d \in \text{Route}} \left[ \alpha \cdot \text{InterestMatch}(d) + \beta \cdot \text{BudgetFit}(d) + \gamma \cdot \text{LocalEconomicScore}(d) \right] - \lambda \sum_{d \in \text{Route}} (\text{Pressure}(d))^2 - \mu \cdot \text{TravelBacktrackPenalty} \right)$$

### Key Properties:
- Strongly avoids recommending regions with $\text{Pressure} > 70$ (Critical) when lower-pressure alternates exist in the corridor.
- Pairs major entry hubs with nearby decentralized gems (e.g., Dehradun $\rightarrow$ Chakrata, Rishikesh $\rightarrow$ Devprayag/Chopta).
- Surfaces verified homestays and community guides directly into daily slots.

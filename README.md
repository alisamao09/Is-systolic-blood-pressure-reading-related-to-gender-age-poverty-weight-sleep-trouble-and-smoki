# Is systolic blood pressure reading related to gender, age, poverty, weight, sleep trouble, and smoking habit? American population-based study

## Overview
This project aims to explore mostly related variables to the change of systolic blood pressure reading (BPSysAve) and the best predictors for combined systolic blood pressure accurate reading in which the effect of smoking (SmokeNow) is to be identified. The dataset drives from ‘NHANES’ survey data collected by the US National Center for Health Statistics (NCHS). The analysis of the effects of the variables will manifest the behaviors or body properties contributing
most to systolic blood pressure to maintain a good health.

## Main process
* Constructed multiple linear regression models and selected the one that has the largest impact on the change of systolic blood pressure and provides the most accurate predictions based on the dataset
* Explored mostly related variables to the change of systolic blood pressure reading (BPSysAve) and the best predictors for combined systolic blood pressure accurate reading
* Checked model inferences, predictability and scalability
* Performed diagnostic check

# Final model interpretation and significance
Blood pressure with men is higher than that with women at similar ages1. The increase in blood pressure with age is mostly associated with artery structural changes2.The huge poverty impact on systolic blood pressure may be attributed to poor medical condition. In addition, obesity leads to artery stiffness, affecting stolid blood pressure, while sleep impacts overall cardiovascular health. Thus, the five selected variables in the final model are most related to affect the change of systolic blood pressure, and provides the most accurate predictions based on the dataset. But SmokeNow is not included for its lack of significant effect on inferences and predictions.The larger number of males, the overall old ages, less amount of sleep and higher weight all lead to a high combined systolic blood pressure (124>120).

## Limitations of analysis and potential
Firstly, the dataset is adapted for educational purposes not suitable for research, with more variables and complex issues to affect blood pressure. Secondly, we only fit multiple linear regression models here, not including non-linear models that may improve prediction accuracy (leading to a low Adjusted R squared). Thirdly, the sample size is not large enough to come up with an all-rounded conclusion. However, this model can explore the effects of five predictors in the model for preliminary systolic blood pressure studies.

## References
1. Reckelhoff, Jane F. "Gender Differences in the Regulation of Blood Pressure." Hypertension 37, no. 5 (2001): 1199-208. doi:10.1161/01.hyp.37.5.1199.
2. Pinto, E. Blood pressure and ageing. Postgrad Med J. 2007;83(976):109-114. doi:10.1136/pgmj.2006.048371.

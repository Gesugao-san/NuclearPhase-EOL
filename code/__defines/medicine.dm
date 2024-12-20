#define BASAL_METABOLIC_RATE 0.7
#define NUTRIENT_START_RATES list(3, 1, 1)
#define NUTRIENT_START_AMOUNT 100

#define OXYGEN_BRAIN_SAFE 10
#define OXYGEN_BRAIN_OKAY 7
#define OXYGEN_BRAIN_BAD 5
#define OXYGEN_BRAIN_SURVIVE 3
#define OXYGEN_DELTA_DIVISOR 37 //a divisor of how much oxygen is actually available to an organ.

#define BPM_2LOW 40
#define BPM_LOW 50
#define BPM_NORMAL 60
#define BPM_HIGH 90
#define BPM_2HIGH 130
#define BPM_AUDIBLE_HEARTRATE 140

#define TPVR_MAX 470
#define TPVR_MIN 57

#define NORMAL_STROKE_VOLUME 70
#define NORMAL_MCV 4200
#define NORMAL_MEAN_PRESSURE 93.2

#define HEMODYNAMICS_INTERPOLATE_FACTOR 0.3

#define BLOOD_PRESSURE_LCRITICAL 65
#define BLOOD_PRESSURE_L2BAD 70
#define BLOOD_PRESSURE_LBAD 80
#define BLOOD_PRESSURE_NORMAL 93
#define BLOOD_PRESSURE_HBAD 130
#define BLOOD_PRESSURE_H2BAD 180
#define BLOOD_PRESSURE_HCRITICAL 200

#define WOUND_TYPE_DEEP "deep" //Won't stop bleeding if bandaged.
#define WOUND_TYPE_BANDAGEABLE "bandageable" //Can be bandaged
#define WOUND_TYPE_STITCHABLE "sticheable" //Should be stitched
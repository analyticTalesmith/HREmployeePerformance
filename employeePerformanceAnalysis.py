import pandas
from scipy.stats import pearsonr
from prettytable import PrettyTable
import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import pairwise_tukeyhsd


#Helper function to format Pearson results; round r to 2 decimal places, and report p to 3 places (or <.001)
def clean_r_for_table(res):
    output = ['','']
    output[0] = round(res[0],2)
    if res[1] >= .001:
        output[1] = round(res[1],3)
    elif res[1] < .001:
        output[1] = "<.001"
    return output

#Create dataframe with column names and set up PrettyTable for easy printing
colNames = ["employee_id", "department", "region", "education", "gender", "recruitment_channel", "no_of_trainings","age","previous_year_rating","length_of_service","KPIs_met_more_than_80","awards_won","avg_training_score"]
df = pandas.read_csv("employees_final_dataset.csv", sep=',', header=0, names=colNames)
out = PrettyTable(['X', 'Y', 'n', 'r', 'df', 'p'])

#Calculate r with pairwise deletion of any rows missing data, and report correlation in table

##Performance and KPI goals
df_cor = df.dropna(axis=0, subset = ["previous_year_rating", "KPIs_met_more_than_80"]);
r = clean_r_for_table(pearsonr(df_cor["previous_year_rating"], df_cor["KPIs_met_more_than_80"]))
out.add_row(["Previous year rating", "KPI Goals Met", df_cor.shape[0], r[0], df_cor.shape[0]-2, r[1]])

print("Correlations")
print(out)

##Reset table and calculate correlations for average training score and number of trainings with performance evaluations and KPI goals
df_cor = df.dropna(axis=0, subset = ["no_of_trainings","previous_year_rating"]);
r = clean_r_for_table(pearsonr(df_cor['no_of_trainings'], df_cor['previous_year_rating']))
out.add_row(["Num of trainings", "Perf Rating", df_cor.shape[0], r[0], df_cor.shape[0]-2, r[1]])

df_cor = df.dropna(axis=0, subset = ["no_of_trainings","KPIs_met_more_than_80"]);
r = clean_r_for_table(pearsonr(df_cor['no_of_trainings'], df_cor['KPIs_met_more_than_80']))
out.add_row(["Num of trainings", "KPI Goals Met", df_cor.shape[0], r[0], df_cor.shape[0]-2, r[1]])

out = PrettyTable(['X', 'Y', 'n', 'r', 'df', 'p'])
df_cor = df.dropna(axis=0, subset = ["avg_training_score","previous_year_rating"]);
r = clean_r_for_table(pearsonr(df_cor['avg_training_score'], df_cor['previous_year_rating']))
out.add_row(["Avg training score", "Perf Rating", df_cor.shape[0], r[0], df_cor.shape[0]-2, r[1]])

df_cor = df.dropna(axis=0, subset = ["avg_training_score","KPIs_met_more_than_80"]);
r = clean_r_for_table(pearsonr(df_cor['avg_training_score'], df_cor['KPIs_met_more_than_80']))
out.add_row(["Avg training score", "KPI Goals Met", df_cor.shape[0], r[0], df_cor.shape[0]-2, r[1]])

print("\nCorrelations")
print(out)

#Is employee performance significantly different based on the no of trainings they complete?
df_tukey = df.dropna(axis=0, subset= ["previous_year_rating", "no_of_trainings"])
model = ols('previous_year_rating ~ C(no_of_trainings)', data=df_tukey).fit()
print("\n\n Mean comparison of performance evaluation by no. of trainings")
print(sm.stats.anova_lm(model, typ=2))

tukey = pairwise_tukeyhsd(endog = df_tukey['previous_year_rating'],
                          groups = df_tukey['no_of_trainings'],
                          alpha = 0.05)
print(tukey)

df_tukey = df.dropna(axis=0, subset= ["KPIs_met_more_than_80", "no_of_trainings"])
model = ols('KPIs_met_more_than_80 ~ C(no_of_trainings)', data=df_tukey).fit()
print("\n\n Mean comparison of meeting KPI goal by no. of trainings")
print(sm.stats.anova_lm(model, typ=2))

tukey = pairwise_tukeyhsd(endog = df_tukey['KPIs_met_more_than_80'],
                          groups = df_tukey['no_of_trainings'],
                          alpha = 0.05)
print(tukey)


#Exploratory analysis to see if performance differs across how employees were recruited
df_tukey = df.dropna(axis=0, subset= ["previous_year_rating", "recruitment_channel"])
model = ols('previous_year_rating ~ C(recruitment_channel)', data=df_tukey).fit()
print("\n\n Mean comparison of performance evals by recruitment channel")
print(sm.stats.anova_lm(model, typ=2))

tukey = pairwise_tukeyhsd(endog = df_tukey['previous_year_rating'],
                          groups = df_tukey['recruitment_channel'],
                          alpha = 0.05)
print(tukey)

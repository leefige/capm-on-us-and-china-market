import pandas as pd

df = pd.read_csv("../data/origin/PMONRET_FF.csv")
neo = pd.DataFrame()
leng = 12 * (2018 - 2008) + 9
neo['Date'] = df['Date'][:leng]
# print(neo)

cols = df.columns
for size in range(1, 6):
    sub_s = df.loc[df['Sizeflg'] == size]
    for bm in range(1, 6):
        sub = sub_s.loc[sub_s['BMflg'] == bm]
        neo['S%dB%d'%(size, bm)] = list(sub['Pmonret_tmv'])

print(neo.shape)
print(neo.columns)
neo.to_csv("../data/cn/ff.csv", encoding='utf-8', index=False)

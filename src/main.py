from sqlalchemy import create_engine
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

username = 'postgres'
password = 'password123'
database_name = 'postgres'
host = 'localhost'
port = '5432'

engine = create_engine(f'postgresql://{username}:{password}@{host}:{port}/{database_name}')

query = """
SELECT country, city, gender, EXTRACT(YEAR FROM AGE(birthday)) AS age 
FROM v_population;
"""

df = pd.read_sql_query(query, engine)

df['age'] = df['age'].astype(float)

# 1. Age Distribution Graph
plt.figure(figsize=(10, 6))
sns.histplot(df['age'], bins=30, kde=False)
plt.title('Age Distribution')
plt.xlabel('Age')
plt.ylabel('Count')
plt.grid(True)
plt.savefig('age_distribution.png')
plt.close()

# 2. Countries Distribution Graph
plt.figure(figsize=(10, 6))
df['country'].value_counts().plot(kind='bar')
plt.title('Countries Distribution')
plt.xlabel('Country')
plt.ylabel('Count')
plt.xticks(rotation=45)
plt.grid(True)
plt.savefig('countries_distribution.png')
plt.close()

# 3. Cities/Countries Distribution Graph
city_country_counts = df.groupby(['country', 'city']).size().unstack().fillna(0)
city_country_counts.plot(kind='bar', stacked=True, figsize=(10, 6))
plt.title('Cities/Countries Distribution')
plt.xlabel('Country')
plt.ylabel('Count')
plt.xticks(rotation=45)
plt.grid(True)
plt.savefig('cities_countries_distribution.png')
plt.close()

# 4. Gender Distribution Graph
plt.figure(figsize=(10, 6))
df['gender'].value_counts().plot(kind='pie', autopct='%1.1f%%')
plt.title('Gender Distribution')
plt.ylabel('')
plt.savefig('gender_distribution.png')
plt.close()

# 5. Age/Gender Distribution Graph
plt.figure(figsize=(10, 6))
sns.boxplot(x='gender', y='age', data=df)
plt.title('Age/Gender Distribution')
plt.xlabel('Gender')
plt.ylabel('Age')
plt.grid(True)
plt.savefig('age_gender_distribution.png')
plt.close()

# 6. Age/Gender/Country Distribution Graph
g = sns.FacetGrid(df, col="country", hue="gender", col_wrap=4, height=4, aspect=1)
g.map(sns.histplot, 'age', bins=15, kde=False)
g.add_legend()
plt.subplots_adjust(top=0.9)
g.fig.suptitle('Age/Gender/Country Distribution')
plt.savefig('age_gender_country_distribution.png')
plt.close()


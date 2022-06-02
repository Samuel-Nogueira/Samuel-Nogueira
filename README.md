```python
import pandas as pd
from datetime import date

date = date.today()
birth = 1993
Age = date.year - birth

lista = []
technical_summary = {
                      'Name': ['Samuel Nogueira']
                    , 'Age': [Age]
                    , 'Languages': ['HTML, Python and SQL']
                    , 'Module_Python': ['Pandas, win32com.client, Selenium and pyodbc']
                    , 'Tools': ['Git']
                    , 'Agile': ['Scrum and Kanban'] 
                    }

lista.append(technical_summary)
df = pd.DataFrame(lista, index=None)

df.head()
```

<center>
  <table>
    <tr>
      <td><img width="400px" align="left" src="https://github-readme-stats.vercel.app/api/top-langs/?username=samuel-nogueira&hide=html&layout=compact&theme=dracula" /></td>
        <td><img width="495px" align="left" src="https://github-readme-stats.vercel.app/api?username=samuel-nogueira&theme=dracula" /></td>
    </tr>   
  </table>
</center>

![Profile views](https://gpvc.arturio.dev/samuel-nogueira)  

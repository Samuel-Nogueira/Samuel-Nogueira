
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager


Caminho_Arquivo = r'Caminho da sua maquina.'
site = 'https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/pagamentos-e-parcelamentos/taxa-de-juros-selic'
options = webdriver.ChromeOptions()
options.add_argument("--headless")

driver = webdriver.Chrome(ChromeDriverManager().install(), chrome_options=options)
driver.get(site)

lista_tabela = []
lista_coluna = []

for x in range(1,14):
    xml = str('/html/body/div[3]/div[1]/main/div[2]/div/div[4]/div/table[2]/tbody/tr[' + str(x) + ']')
    
    tabela =  driver.find_element_by_xpath(xml).text
    if x == 1:
        lista_coluna.append(tabela.split(' '))
        
    lista_tabela.append(tabela.split(' '))

df = pd.DataFrame(lista_tabela, columns=lista_coluna)

df_tratado = df.drop(0)

tabela_pivot = df_tratado.melt(id_vars=['Mês/Ano'], var_name='Ano', value_name='Taxa', col_level=0)
tabela_pivot.drop(tabela_pivot.loc[tabela_pivot['Taxa'].isnull()].index, inplace=True)

for x in range(0,max(tabela_pivot.index)+1):
    tabela_pivot['Taxa'][x] = tabela_pivot['Taxa'][x].replace('%','')
    tabela_pivot['Taxa'][x] = tabela_pivot['Taxa'][x].replace(',','.')
    tabela_pivot['Taxa'][x] = float(tabela_pivot['Taxa'][x]) / 100

tabela_pivot.to_csv(Caminho_Arquivo, index=False)

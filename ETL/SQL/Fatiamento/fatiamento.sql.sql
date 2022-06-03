set dateformat dmy
set nocount on

declare @data_PROC smalldatetime
declare @data_MOVTO smalldatetime
declare @Corp varchar(max)


	/*Neste tipo de Bulk insert não funciona com tabela temporaria,
	se faz necessário uma tabela fisica, pois a tabela temporaria perde
	a classificação de entrada do arquivo, sendo asssim, removendo a ordenação das
	linhas do arquivo.
	É necessário criar uma tabela fisíca para manter a ordem do arquivo de entrada.
	É importante manter a ordem, para que possamos saber qual linha pertece a cada nota.*/
	truncate table tb_fatiamento_stg;
;	bulk insert tb_fatiamento_stg 
	from 'C:\Users\Administrator\Documents\S1\ArquivoModelo.S1'
	with(codepage = 'ACP');
	
------------------------------------------------------------------------------------------------------------------
/*Variaveis fixas para formar as colunas de informaçoes fixas.*/
set @data_PROC = (
					select distinct right(left(substring(coluna,CHARINDEX('proc ',coluna,1),len(coluna)),13),8) 
					from tb_fatiamento_stg
					where substring(coluna,CHARINDEX('proc ',coluna,1),len(coluna)) like '%proc %'
				 )

set @data_MOVTO = (
					select distinct right(left(substring(coluna,CHARINDEX('MOVTO ',coluna,1),len(coluna)),14),8)
					from tb_fatiamento_stg
					where substring(coluna,CHARINDEX('MOVTO ',coluna,1),len(coluna)) like '%MOVTO %'
				 )

set @Corp =		(
					select distinct right(left(substring(coluna,CHARINDEX('CORP ',coluna,1),len(coluna)),8),3)
					from tb_fatiamento_stg
					where substring(coluna,CHARINDEX('CORP ',coluna,1),len(coluna)) like '%CORP %'
				 )

------------------------------------------------------------------------------------------------------------------

/*Cria um novo objeto temporário para efeturar os fatiamos com base nas 
referncias que serão criadas a seguir.*/
if OBJECT_ID('tempdb.dbo.#fatiamento') is not null drop table #fatiamento
select 
	 convert(date,@data_PROC )	as data_PROC
	,convert(date,@data_MOVTO) 	as data_MOVTO
	,@Corp			as Corp
	,ROW_NUMBER() over (order by @Corp ) IdCursor
    
	,coluna
	,[master].[dbo].[SeparetesColumns](coluna,4,' ')					   NumeroCartao
	
	,left(ltrim(substring(Coluna,CHARINDEX(' ',Coluna,65),len(Coluna))),2) DC				
	,rtrim(ltrim(left(substring(Coluna,25,len(Coluna)),21)))			   cpf_cgc		
	,left(ltrim(substring(Coluna,CHARINDEX(' ',Coluna,67),len(Coluna))),7) VL_SEG			
	,left(ltrim(substring(Coluna,CHARINDEX(' ',Coluna,72),len(Coluna))),7) VL_Cobrado	

	into #fatiamento

from tb_fatiamento_stg;

------------------------------------------------------------------------------------------------------------------
/*gera a referencia de incio de cada nota*/

alter table #fatiamento add Referencia int;
alter table #fatiamento add ReffCursor int;

if(object_id('tempdb..#Reff') is not null) begin drop table #Reff end
SELECT 
	*
	,dense_rank() over(partition by coluna order by IdCursor) as Reff
		
	into #Reff

FROM #fatiamento nolock
where coluna like '%Å%'
order by IdCursor;

update a
set a.Referencia = b.Reff
from #fatiamento as a
inner join #Reff as b
on a.IdCursor = b.IdCursor;

------------------------------------------------------------------------------------------------------------------
/*Gera referencia para orientar a qual nota cada linha pertence*/

declare  @Referencia int
		,@Inicio	 int
		,@Fim		 int
		,@IdCursor	 int
		,@ReffCursor int;

declare c_Referencia cursor for
select IdCursor,Referencia
from #fatiamento nolock
order by IdCursor

open c_Referencia
fetch next from c_Referencia into @IdCursor,@Referencia

set @ReffCursor = 0

WHILE @@FETCH_STATUS = 0 
	begin 

		set @Inicio = 1
		set @fim = max(@IdCursor)

		while @Inicio <= @Fim 
			begin
					if @Referencia is null
						begin
							set @Inicio = @Inicio + 1
						end		
					else
						begin
							set @Inicio = @Inicio + 1
							set @ReffCursor = @Referencia
						end
	end

	update #fatiamento set ReffCursor = @ReffCursor
	where IdCursor = @Inicio

fetch next from c_Referencia into @IdCursor,@Referencia

	end
close c_Referencia
deallocate c_Referencia;

/*query que gera os dados para inserir na tabela de produção*/
select 
	 a.data_PROC
	,a.data_MOVTO
	,a.Corp
	,b.CodProd		
	,b.CodSubProd	
	,b.NomeProd	 
	,c.CodigoOffers	
	,c.ServDescr	
	,d.CodCanal	
	,d.IdOper	
	,e.CodCampanha
	,a.NumeroCartao	
	,a.DC	
	,a.CPF_CGC	
	,a.VL_SEG	
	,a.VL_Cobrado

from
	(
	select * from #fatiamento 
	where len(NumeroCartao) = 18 /*sempre que a linha desta coluna conter 18 caracters 
									quer dizer que é uma linha de com o produto da nota*/

	)as a
inner join (
			select 
			 a.ReffCursor
			,rtrim(ltrim(left(substring(Coluna,CHARINDEX(' ',Coluna,1),len(Coluna)),5))) as CodProd
			,rtrim(ltrim(right(left(substring(Coluna,CHARINDEX(' ',Coluna,1),len(Coluna)),10),4))) as CodSubProd
			,rtrim(ltrim(substring(Coluna,15,len(Coluna)))) as NomeProd

			from #fatiamento as a
			where CHARINDEX(' / ',Coluna,1) = 6 
			) as b
			on a.ReffCursor = b.ReffCursor

inner join (
			select 
			 a.ReffCursor
			 ,rtrim(ltrim(substring(Coluna,33,len(Coluna)))) as CodigoOffers
			 ,[master].[dbo].[SeparetesColumns](coluna,21,' ') as ServDescr
			from #fatiamento as a
			where CHARINDEX('CODIGO OFFERS',Coluna,1) = 3
			) as c
			on a.ReffCursor = c.ReffCursor

inner join (
			select 
			 a.ReffCursor
			 ,[master].[dbo].[SeparetesColumns](coluna,11,' ')  as CodCanal
			 ,rtrim(ltrim(substring(Coluna,30,len(Coluna))))	as IdOper
			from #fatiamento as a
			where CHARINDEX('CODIGO CANAL',Coluna,1)  = 3
			) as d
			on a.ReffCursor = d.ReffCursor

inner join (
			select 
			 a.ReffCursor
			 ,[master].[dbo].[SeparetesColumns](coluna,8,' ')	as CodCampanha
			from #fatiamento as a
			where CHARINDEX('CODIGO CAMPANHA',Coluna,1)   = 3
			) as e
			on a.ReffCursor = e.ReffCursor
order by a.idcursor;
CREATE TABLE [dbo].[Fatiado](
	[data_PROC] [smalldatetime] NULL,
	[data_MOVTO] [smalldatetime] NULL,
	[Corp] [varchar](50) NULL,
	[IdCursor] [int] NULL,
	[Coluna] [varchar](5000) NULL,
	[CodProd] [varchar](50) NULL,
	[Referencia] [int] NULL,
	[ReffCursor] [int] NULL,
	[CodSubProd] [varchar](50) NULL,
	[NomeProd] [varchar](2000) NULL,
	[CodigoOffers] [varchar](2000) NULL,
	[ServDescr] [varchar](2000) NULL,
	[CodCanal] [varchar](2000) NULL,
	[IdOper] [varchar](2000) NULL,
	[CodCampanha] [varchar](2000) NULL,
	[NumeroCartao] [varchar](2000) NULL,
	[DC] [varchar](2000) NULL,
	[CPF_CGC] [varchar](2000) NULL,
	[VL_SEG] [varchar](2000) NULL,
	[VL_Cobrado] [varchar](2000) NULL
) ON [PRIMARY]
GO


CREATE CLUSTERED INDEX idx_coluna ON [dbo].[Fatiado] (IdCursor);
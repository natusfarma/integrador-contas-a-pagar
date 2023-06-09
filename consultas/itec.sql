SELECT 
		LEFT(CASE 
			WHEN CHARINDEX('-', PG_CRED.NR_TIT) = 0
			THEN ISNULL(CONVERT(VARCHAR(MAX), 0), 'K' + CONVERT(VARCHAR(MAX), ABS(CONVERT(INT, CONVERT(BINARY(4), NEWID())))))	
			ELSE RIGHT(CONVERT(VARCHAR(MAX), CONVERT(BIGINT, SUBSTRING(PG_CRED.NR_TIT, 0, CHARINDEX('-', PG_CRED.NR_TIT, 0)))), 9)
		END, 9)																												AS TITULO,
		PG_CRED.CD_FORN																								AS CODFORN,
		ISNULL(PG_FORN.NM_FANT, '') 																			AS NMFORN,
		PG_CRED.DT_EMIS																								AS DT_EMISSAO,
		PRC_GRP_ECON.NM_GRP_ECON 																		AS NMGRPECON,
		CASE
			WHEN ISNULL(PG_CRED_BLQ.CD_PG_CRED, 0) > 0 THEN 'SIM'
			ELSE 'NAO'
		END 																													DUP_BLOQUEADA,
		PG_CRED.CD_FILIAL																							AS FILIAL,
		PG_CRED.DT_CAD 																								AS DT_CAD_DP,
		PG_CRED.DT_VENCTO																							AS DT_VENCIMENTO,
		PG_CRED.VLR_DP 																								AS VALOR,
		PG_CRED.VLR_JUROS 																						    AS VLR_JUROS,
		ISNULL(PG_CRED.VLR_DESC, 0) 																		AS VLR_DESC,
		PG_CRED.VLR_DESP_OUTR 																					AS VLR_OUTRDESP,
		ISNULL(PG_CRED.VLR_DEVOLUCAO, 0) 																AS VLR_DEVOLUCAO,
		ISNULL(V_PG_CRED_IMPOSTO.VLR_IMP, 0) 														AS VLR_IMP,
		(PG_CRED.VLR_DP + ISNULL(PG_CRED.VLR_JUROS, 0) + ISNULL(PG_CRED.VLR_DESP_OUTR, 0)) - (ISNULL(PG_CRED.VLR_DESC, 0) + ISNULL(V_PG_CRED_IMPOSTO.VLR_IMP, 0)+ ISNULL(PG_CRED.VLR_DEVOLUCAO, 0)) AS VLR_LIQ,
		'0'																														AS NUM_NOTA,
		PG_CRED.PARC																									AS PARCELA
	   
FROM PG_CRED
	INNER JOIN PG_FORN ON PG_CRED.CD_EMP = PG_FORN.CD_EMP 
			AND PG_CRED.CD_FORN = PG_FORN.CD_FORN
	LEFT OUTER JOIN PG_CRED_BLQ ON PG_CRED_BLQ.CD_EMP = PG_CRED.CD_EMP
			AND PG_CRED_BLQ.CD_FILIAL = PG_CRED.CD_FILIAL
			AND PG_CRED_BLQ.CD_PG_CRED = PG_CRED.CD_PG_CRED
	INNER JOIN PRC_GRP_ECON_PRC_FILIAL ON PG_CRED.CD_EMP = PRC_GRP_ECON_PRC_FILIAL.CD_EMP
			AND PG_CRED.CD_FILIAL = PRC_GRP_ECON_PRC_FILIAL.CD_FILIAL
	INNER JOIN PRC_GRP_ECON ON PRC_GRP_ECON_PRC_FILIAL.CD_GRP_ECON = PRC_GRP_ECON.CD_GRP_ECON
	LEFT OUTER JOIN V_PG_CRED_IMPOSTO ON PG_CRED.CD_EMP = V_PG_CRED_IMPOSTO.CD_EMP
			AND PG_CRED.CD_FILIAL = V_PG_CRED_IMPOSTO.CD_FILIAL
			AND PG_CRED.CD_PG_CRED = V_PG_CRED_IMPOSTO.CD_PG_CRED
	WHERE PG_CRED.CD_EMP = 1
			--AND PG_CRED.STS_DP IN (0,2)
			AND PG_CRED.STS_DP <> 3
			AND NOT EXISTS
								(SELECT *
								FROM PRC_FILIAL_PG_FORN
								WHERE PG_FORN.CD_EMP = PRC_FILIAL_PG_FORN.CD_EMP
										AND PG_FORN.CD_FORN = PRC_FILIAL_PG_FORN.CD_FORN)